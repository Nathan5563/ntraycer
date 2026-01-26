// COMPLETE
/**
 * This module implements triangle and quad primitives for rendering
 * planar geometry like walls, floors, and complex meshes.
 */
module cpu.scene.hittable.mesh;

import cpu.accel.aabb : AABB;
import cpu.accel.bvh : Boundable;
import cpu.core.math : Vec3, Ray, RNG, abs, min, max, EPSILON;
import cpu.scene.hittable.hittable : Hittable, HitInfo;
import cpu.scene.light : Light, LightSample;
import cpu.scene.material.material : Material;
import cpu.scene.material.emissive : Emissive;

/// @class Triangle - A single triangle primitive
class Triangle : Hittable, Boundable
{
    private Vec3 v0, v1, v2;
    private Vec3 normal;
    private Material material;

    /// @func this - Creates a triangle from three vertices
    ///
    /// @param v0, v1, v2 - the three vertices (counter-clockwise winding)
    /// @param material - the material for the triangle
    this(Vec3 v0, Vec3 v1, Vec3 v2, Material material)
    {
        this.v0 = v0;
        this.v1 = v1;
        this.v2 = v2;
        this.material = material;

        // Compute face normal
        Vec3 edge1 = v1 - v0;
        Vec3 edge2 = v2 - v0;
        this.normal = edge1.cross(edge2).normalized();
    }

    /// @func hit - Möller–Trumbore ray-triangle intersection
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        Vec3 edge1 = v1 - v0;
        Vec3 edge2 = v2 - v0;
        Vec3 h = r.direction.cross(edge2);
        float a = edge1.dot(h);

        // Ray parallel to triangle
        if (abs(a) < EPSILON)
            return false;

        float f = 1.0f / a;
        Vec3 s = r.origin - v0;
        float u = f * s.dot(h);

        if (u < 0.0f || u > 1.0f)
            return false;

        Vec3 q = s.cross(edge1);
        float v = f * r.direction.dot(q);

        if (v < 0.0f || u + v > 1.0f)
            return false;

        float t = f * edge2.dot(q);

        if (t > timeMin && t < timeMax)
        {
            hitInfo.time = t;
            hitInfo.point = r.at(t);
            hitInfo.setFaceNormal(r, normal);
            hitInfo.material = cast(Material) material;
            return true;
        }

        return false;
    }

    /// @func boundingBox - Returns the axis-aligned bounding box of the triangle
    AABB boundingBox() const
    {
        return AABB(
            Vec3(
                min(v0.x, min(v1.x, v2.x)) - EPSILON,
                min(v0.y, min(v1.y, v2.y)) - EPSILON,
                min(v0.z, min(v1.z, v2.z)) - EPSILON
            ),
            Vec3(
                max(v0.x, max(v1.x, v2.x)) + EPSILON,
                max(v0.y, max(v1.y, v2.y)) + EPSILON,
                max(v0.z, max(v1.z, v2.z)) + EPSILON
            )
        );
    }

    /// @func getVertices - Returns the triangle vertices (for GPU export)
    void getVertices(out Vec3 ov0, out Vec3 ov1, out Vec3 ov2) const
    {
        ov0 = v0;
        ov1 = v1;
        ov2 = v2;
    }

    /// @func getMaterial - Returns the material (for GPU export)
    Material getMaterial() const
    {
        return cast(Material) material;
    }
}

/// @class Quad - A quadrilateral (two triangles) for walls/floors
class Quad : Hittable, Boundable, Light
{
    private Triangle tri1;
    private Triangle tri2;
    private Vec3 v0, v1, v2, v3;
    private Vec3 normal;
    private Material material;

    /// @func this - Creates a quad from four vertices
    ///
    /// @param v0, v1, v2, v3 - four vertices in counter-clockwise order
    /// @param material - the material for the quad
    this(Vec3 v0, Vec3 v1, Vec3 v2, Vec3 v3, Material material)
    {
        this.v0 = v0;
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
        this.material = material;

        // Compute normal from edges
        Vec3 edge1 = v1 - v0;
        Vec3 edge2 = v3 - v0;
        this.normal = edge1.cross(edge2).normalized();

        // Split quad into two triangles
        this.tri1 = new Triangle(v0, v1, v2, material);
        this.tri2 = new Triangle(v0, v2, v3, material);
    }

    /// @func hit - Tests ray against both triangles
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        if (tri1.hit(r, timeMin, timeMax, hitInfo))
            return true;
        return tri2.hit(r, timeMin, timeMax, hitInfo);
    }

    /// @func boundingBox - Returns the axis-aligned bounding box of the quad
    AABB boundingBox() const
    {
        return tri1.boundingBox().merge(tri2.boundingBox());
    }

    /// @func sampleLight - Samples a random point on the quad for direct lighting
    ///
    /// @param hitPoint - the point being illuminated
    /// @param rng - random number generator
    LightSample sampleLight(Vec3 hitPoint, ref RNG rng) const
    {
        LightSample sample;

        // Sample uniformly on the quad using barycentric interpolation
        float u = rng.nextFloat();
        float v = rng.nextFloat();

        // Bilinear interpolation on quad
        Vec3 p0 = v0 + (v1 - v0) * u;
        Vec3 p1 = v3 + (v2 - v3) * u;
        sample.point = p0 + (p1 - p0) * v;
        sample.normal = normal;

        // Compute area for PDF (area measure)
        float a = area();
        sample.pdfArea = 1.0f / a;
        sample.area = a;

        // Get emission from material
        sample.emission = getEmission();

        return sample;
    }

    /// @func getEmission - Returns the emission if material is emissive
    Vec3 getEmission() const
    {
        Emissive emissive = cast(Emissive) cast(Material) material;
        if (emissive !is null)
            return emissive.emit();
        return Vec3(0, 0, 0);
    }

    /// @func getArea - Returns the surface area of the quad
    float getArea() const
    {
        return area();
    }

    /// @func getPdfArea - Returns the area PDF (1/area for uniform sampling)
    float getPdfArea() const
    {
        return 1.0f / area();
    }

    /// @func isEmissive - Returns true if this quad has an emissive material
    bool isEmissive() const
    {
        return (cast(Emissive) cast(Material) material) !is null;
    }

    /// @func area - Returns the area of the quad
    float area() const
    {
        Vec3 edge1 = v1 - v0;
        Vec3 edge2 = v3 - v0;
        return edge1.cross(edge2).norm();
    }

    /// @func getNormal - Returns the quad normal
    Vec3 getNormal() const
    {
        return normal;
    }

    /// @func getVertices - Returns the quad vertices (for GPU export)
    void getVertices(out Vec3 ov0, out Vec3 ov1, out Vec3 ov2, out Vec3 ov3) const
    {
        ov0 = v0;
        ov1 = v1;
        ov2 = v2;
        ov3 = v3;
    }

    /// @func getMaterial - Returns the material (for GPU export)
    Material getMaterial() const
    {
        return cast(Material) material;
    }
}

unittest
{
    import cpu.core.math : fequals;
    import cpu.scene.material.lambertian : Lambertian;

    // Test Triangle intersection
    auto mat = new Lambertian(Vec3(1, 0, 0));
    auto tri = new Triangle(
        Vec3(-1, 0, 0),
        Vec3(1, 0, 0),
        Vec3(0, 1, 0),
        mat
    );

    // Ray hitting center of triangle
    Ray ray = Ray(Vec3(0, 0.3f, -5), Vec3(0, 0, 1));
    HitInfo hitInfo;
    bool hit = tri.hit(ray, 0.001f, float.infinity, hitInfo);
    assert(hit == true);
    assert(fequals(hitInfo.point.z, 0.0f));

    // Ray missing triangle
    Ray missRay = Ray(Vec3(5, 5, -5), Vec3(0, 0, 1));
    bool miss = tri.hit(missRay, 0.001f, float.infinity, hitInfo);
    assert(miss == false);

    // Test Quad
    auto quad = new Quad(
        Vec3(-1, -1, 0),
        Vec3(1, -1, 0),
        Vec3(1, 1, 0),
        Vec3(-1, 1, 0),
        mat
    );

    Ray quadRay = Ray(Vec3(0, 0, -5), Vec3(0, 0, 1));
    bool quadHit = quad.hit(quadRay, 0.001f, float.infinity, hitInfo);
    assert(quadHit == true);
}

