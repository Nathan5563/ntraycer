// COMPLETE
/**
 * This module defines the Scene class which holds all objects, the camera,
 * and background for rendering. It implements Hittable to allow ray testing
 * against all objects in the scene, using BVH acceleration for faster
 * intersection tests.
 */
module cpu.scene.scene;

import cpu.accel.aabb : AABB;
import cpu.accel.bvh : BVHAccelerator, BVHNode;
import cpu.core.math : Vec3, Ray, RNG;
import cpu.scene.camera.camera : Camera;
import cpu.scene.camera.pinhole : PinholeCamera;
import cpu.scene.hittable.hittable : Hittable, HitInfo;
import cpu.scene.hittable.sphere : Sphere;
import cpu.scene.hittable.mesh : Triangle, Quad;
import cpu.scene.background : Background, skyBackground, SolidBackground;
import cpu.scene.light : Light, LightSample;
import cpu.scene.material.material : Material;
import cpu.scene.material.lambertian : Lambertian;
import cpu.scene.material.metal : Metal;
import cpu.scene.material.dielectric : Dielectric;
import cpu.scene.material.emissive : Emissive;
import gpu.scene;

/// @class Scene - Container for all renderable objects, camera, and background
class Scene : Hittable
{
    /// @prop camera - the camera used to generate rays
    Camera camera;
    /// @prop background - the background/environment for missed rays
    Background background;
    private Hittable[] objects;
    private BVHAccelerator bvh;
    private Light[] lights;

    /// @func this - Creates an empty scene with default sky background
    this()
    {
        this.camera = null;
        this.background = skyBackground();
        this.objects = [];
        this.bvh = null;
        this.lights = [];
    }

    /// @func this - Creates a scene with camera and objects, default sky background
    ///
    /// @param camera - the camera for the scene
    /// @param objects - array of hittable objects
    this(Camera camera, Hittable[] objects)
    {
        this.camera = camera;
        this.background = skyBackground();
        this.objects = objects;
        this.bvh = new BVHAccelerator(objects);
        this.lights = findLights(objects);
    }

    /// @func this - Creates a scene with camera, objects, and custom background
    ///
    /// @param camera - the camera for the scene
    /// @param objects - array of hittable objects
    /// @param background - custom background
    this(Camera camera, Hittable[] objects, Background background)
    {
        this.camera = camera;
        this.background = background;
        this.objects = objects;
        this.bvh = new BVHAccelerator(objects);
        this.lights = findLights(objects);
    }

    /// @func findLights - Finds all objects implementing Light interface
    private static Light[] findLights(Hittable[] objects)
    {
        Light[] result;
        foreach (obj; objects)
        {
            Light light = cast(Light) obj;
            if (light !is null && light.getEmission().norm() > 0)
                result ~= light;
        }
        return result;
    }

    /// @func hasLights - Returns true if scene has any light sources
    bool hasLights() const
    {
        return lights.length > 0;
    }

    /// @func sampleLight - Samples a random light and point on it
    ///
    /// @param hitPoint - the point being illuminated
    /// @param rng - random number generator
    /// @param lightSample - output light sample
    bool sampleLight(Vec3 hitPoint, ref RNG rng, out LightSample lightSample) const
    {
        if (lights.length == 0)
            return false;

        // Randomly select a light
        size_t idx = cast(size_t)(rng.nextFloat() * lights.length);
        if (idx >= lights.length)
            idx = lights.length - 1;

        lightSample = lights[idx].sampleLight(hitPoint, rng);
        // Adjust pdfArea for light selection probability
        lightSample.pdfArea /= cast(float) lights.length;
        return true;
    }

    /// @func hit - Tests a ray against BVH-accelerated objects, returning the closest hit
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        if (bvh !is null)
            return bvh.hit(r, timeMin, timeMax, hitInfo);

        // Fallback to linear search if no BVH
        HitInfo tmpHit;
        bool hitAnything = false;
        float closestHit = timeMax;
        foreach (obj; this.objects)
        {
            if (obj.hit(r, timeMin, closestHit, tmpHit))
            {
                hitAnything = true;
                closestHit = tmpHit.time;
                hitInfo = tmpHit;
            }
        }
        return hitAnything;
    }

    /// @func toGPU - Exports the scene to GPU-friendly data structures
    ///
    /// @returns - GPUSceneData ready for upload to compute shader SSBOs
    GPUSceneData toGPU() const
    {
        GPUSceneData data;

        // Material deduplication map (using object identity via hash)
        size_t[size_t] materialIndexMap;
        
        // Flatten primitives and collect materials
        foreach (obj; objects)
        {
            if (auto sphere = cast(Sphere) obj)
            {
                uint matIdx = getOrAddMaterial(sphere.getMaterial(), data.materials, materialIndexMap);
                
                GPUPrimitive prim;
                prim.type = GPUPrimitiveType.Sphere;
                prim.materialIndex = matIdx;
                Vec3 c = sphere.getCenter();
                prim.data[0] = c.x;
                prim.data[1] = c.y;
                prim.data[2] = c.z;
                prim.data[3] = sphere.getRadius();
                data.primitives ~= prim;
            }
            else if (auto quad = cast(Quad) obj)
            {
                // Split quad into two triangles
                uint matIdx = getOrAddMaterial(quad.getMaterial(), data.materials, materialIndexMap);
                
                Vec3 v0, v1, v2, v3;
                quad.getVertices(v0, v1, v2, v3);
                
                // Triangle 1: v0, v1, v2
                GPUPrimitive tri1;
                tri1.type = GPUPrimitiveType.Triangle;
                tri1.materialIndex = matIdx;
                tri1.data[0] = v0.x; tri1.data[1] = v0.y; tri1.data[2] = v0.z;
                tri1.data[4] = v1.x; tri1.data[5] = v1.y; tri1.data[6] = v1.z;
                tri1.data[8] = v2.x; tri1.data[9] = v2.y; tri1.data[10] = v2.z;
                data.primitives ~= tri1;
                
                // Triangle 2: v0, v2, v3
                GPUPrimitive tri2;
                tri2.type = GPUPrimitiveType.Triangle;
                tri2.materialIndex = matIdx;
                tri2.data[0] = v0.x; tri2.data[1] = v0.y; tri2.data[2] = v0.z;
                tri2.data[4] = v2.x; tri2.data[5] = v2.y; tri2.data[6] = v2.z;
                tri2.data[8] = v3.x; tri2.data[9] = v3.y; tri2.data[10] = v3.z;
                data.primitives ~= tri2;
            }
            else if (auto triangle = cast(Triangle) obj)
            {
                uint matIdx = getOrAddMaterial(triangle.getMaterial(), data.materials, materialIndexMap);
                
                Vec3 v0, v1, v2;
                triangle.getVertices(v0, v1, v2);
                
                GPUPrimitive tri;
                tri.type = GPUPrimitiveType.Triangle;
                tri.materialIndex = matIdx;
                tri.data[0] = v0.x; tri.data[1] = v0.y; tri.data[2] = v0.z;
                tri.data[4] = v1.x; tri.data[5] = v1.y; tri.data[6] = v1.z;
                tri.data[8] = v2.x; tri.data[9] = v2.y; tri.data[10] = v2.z;
                data.primitives ~= tri;
            }
        }

        // Linearize BVH
        if (bvh !is null)
        {
            linearizeBVH(bvh.getRoot(), data.bvhNodes, objects);
        }

        // Export camera
        if (auto pinhole = cast(PinholeCamera) camera)
        {
            Vec3 pos = pinhole.position();
            Vec3 ll = pinhole.getLowerLeft();
            Vec3 h = pinhole.getHorizontal();
            Vec3 v = pinhole.getVertical();
            
            data.camera.origin = GPUVec3(pos.x, pos.y, pos.z, 0);
            data.camera.lowerLeft = GPUVec3(ll.x, ll.y, ll.z, 0);
            data.camera.horizontal = GPUVec3(h.x, h.y, h.z, 0);
            data.camera.vertical = GPUVec3(v.x, v.y, v.z, 0);
        }

        // Export background
        if (auto solid = cast(SolidBackground) background)
        {
            Vec3 c = solid.getColor();
            data.backgroundColor = GPUVec3(c.x, c.y, c.z, 0);
            data.hasSolidBackground = true;
        }
        else
        {
            // Default to black for non-solid backgrounds (GPU can implement gradient)
            data.backgroundColor = GPUVec3(0, 0, 0, 0);
            data.hasSolidBackground = false;
        }

        return data;
    }

    /// Helper to get or add a material to the GPU materials array
    private static uint getOrAddMaterial(
        Material mat,
        ref GPUMaterial[] materials,
        ref size_t[size_t] indexMap
    ) {
        size_t id = cast(size_t) cast(void*) mat;
        
        if (id in indexMap)
            return cast(uint) indexMap[id];
        
        GPUMaterial gpuMat;
        
        if (auto lamb = cast(Lambertian) mat)
        {
            gpuMat.type = GPUMaterialType.Lambertian;
            Vec3 a = lamb.getAlbedo();
            gpuMat.albedo = GPUVec3(a.x, a.y, a.z, 0);
            gpuMat.param1 = 0;
        }
        else if (auto metal = cast(Metal) mat)
        {
            gpuMat.type = GPUMaterialType.Metal;
            Vec3 a = metal.getAlbedo();
            gpuMat.albedo = GPUVec3(a.x, a.y, a.z, 0);
            gpuMat.param1 = metal.getFuzz();
        }
        else if (auto diel = cast(Dielectric) mat)
        {
            gpuMat.type = GPUMaterialType.Dielectric;
            gpuMat.albedo = GPUVec3(1, 1, 1, 0);  // Glass is colorless
            gpuMat.param1 = diel.getIOR();
        }
        else if (auto emit = cast(Emissive) mat)
        {
            gpuMat.type = GPUMaterialType.Emissive;
            Vec3 c = emit.getEmitColor();
            gpuMat.albedo = GPUVec3(c.x, c.y, c.z, 0);
            gpuMat.param1 = emit.getIntensity();
        }
        
        uint idx = cast(uint) materials.length;
        materials ~= gpuMat;
        indexMap[id] = idx;
        return idx;
    }

    /// Linearize BVH tree to flat array for GPU traversal
    private static int linearizeBVH(
        const BVHNode node,
        ref GPUBVHNode[] nodes,
        const Hittable[] objects
    ) {
        if (node is null)
            return -1;
        
        int myIndex = cast(int) nodes.length;
        GPUBVHNode gpuNode;
        
        auto box = node.boundingBox();
        gpuNode.aabbMin = GPUVec3(box.minPoint.x, box.minPoint.y, box.minPoint.z, 0);
        gpuNode.aabbMax = GPUVec3(box.maxPoint.x, box.maxPoint.y, box.maxPoint.z, 0);
        
        nodes ~= gpuNode;  // Reserve slot
        
        if (node.isLeaf())
        {
            // Leaf node - find primitive index
            // For now, store -1 as we're using a simple primitive array
            // In practice, you'd map the primitive to its index
            nodes[myIndex].leftChild = -1;
            nodes[myIndex].rightChild = -1;
            nodes[myIndex].primStart = findPrimitiveIndex(node.getPrimitive(), objects);
            nodes[myIndex].primCount = 1;
        }
        else
        {
            // Internal node
            nodes[myIndex].primCount = 0;
            nodes[myIndex].primStart = -1;
            nodes[myIndex].leftChild = linearizeBVH(node.getLeft(), nodes, objects);
            nodes[myIndex].rightChild = linearizeBVH(node.getRight(), nodes, objects);
        }
        
        return myIndex;
    }

    /// Find the index of a primitive in the objects array
    private static int findPrimitiveIndex(const Hittable prim, const Hittable[] objects)
    {
        foreach (i, obj; objects)
        {
            if (cast(void*) obj == cast(void*) prim)
                return cast(int) i;
        }
        return -1;
    }
}

unittest
{
    import cpu.core.math : fequals;

    // Test empty scene creation
    auto emptyScene = new Scene();
    assert(emptyScene.camera is null);
    assert(emptyScene.background !is null);

    // Test scene with objects
    auto mat = new Lambertian(Vec3(1, 0, 0));
    Hittable[] objects = [
        new Sphere(Vec3(0, 0, -5), 1.0f, mat),
        new Sphere(Vec3(0, 0, -10), 1.0f, mat)
    ];
    auto scene = new Scene(null, objects);

    // Ray should hit closest sphere first
    Ray ray = Ray(Vec3(0, 0, 0), Vec3(0, 0, -1));
    HitInfo hitInfo;
    bool hit = scene.hit(ray, 0.001f, float.infinity, hitInfo);

    assert(hit == true);
    assert(fequals(hitInfo.time, 4.0f));  // Closest sphere at z=-5, radius 1

    // Ray missing all objects
    Ray missRay = Ray(Vec3(10, 0, 0), Vec3(0, 0, -1));
    bool miss = scene.hit(missRay, 0.001f, float.infinity, hitInfo);
    assert(miss == false);

    // Test scene with custom background
    auto customBg = new SolidBackground(Vec3(0.1f, 0.1f, 0.1f));
    auto customScene = new Scene(null, objects, customBg);
    assert(customScene.background is customBg);
}
