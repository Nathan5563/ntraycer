// COMPLETE
/**
 * This module defines the Scene class which holds all objects, the camera,
 * and background for rendering. It implements Hittable to allow ray testing
 * against all objects in the scene, using BVH acceleration for faster
 * intersection tests.
 */
module lib.scene.scene;

import lib.accel.bvh : BVHAccelerator;
import lib.core.math : Vec3, Ray, RNG;
import lib.scene.camera.camera : Camera;
import lib.scene.hittable.hittable : Hittable, HitInfo;
import lib.scene.background : Background, skyBackground;

/// @class Scene - Container for all renderable objects, camera, and background
class Scene : Hittable
{
    /// @prop camera - the camera used to generate rays
    Camera camera;
    /// @prop background - the background/environment for missed rays
    Background background;
    private Hittable[] objects;
    private BVHAccelerator bvh;

    /// @func this - Creates an empty scene with default sky background
    this()
    {
        this.camera = null;
        this.background = skyBackground();
        this.objects = [];
        this.bvh = null;
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
}

unittest
{
    import lib.core.math : fequals;
    import lib.scene.hittable.sphere : Sphere;
    import lib.scene.material.lambertian : Lambertian;
    import lib.scene.background : SolidBackground;

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
