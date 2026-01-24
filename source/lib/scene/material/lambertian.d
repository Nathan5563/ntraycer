// COMPLETE
/**
 * This module implements the Lambertian (diffuse) material which scatters
 * light uniformly in all directions from the surface normal.
 */
module lib.scene.material.lambertian;

import lib.core.math : Vec3, Ray, RNG;
import lib.scene.material.material : Material, ScatterResult;
import lib.scene.hittable.hittable : HitInfo;

/// @class Lambertian - A diffuse material that scatters light randomly
class Lambertian : Material
{
    private Vec3 albedo;

    /// @func this - Creates a new Lambertian material
    ///
    /// @param albedo - the base color/reflectance of the surface
    this(Vec3 albedo)
    {
        this.albedo = albedo;
    }

    /// @func scatter - Scatters the ray in a random direction around the normal
    override bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const
    {
        Vec3 scatterDirection = hitInfo.normal + rng.randomUnitVector();

        // Catch degenerate scatter direction
        const float lenSq = scatterDirection.x * scatterDirection.x +
                            scatterDirection.y * scatterDirection.y +
                            scatterDirection.z * scatterDirection.z;
        if (lenSq < 1e-8f)
        {
            scatterDirection = hitInfo.normal;
        }

        result.scattered = Ray(hitInfo.point, scatterDirection);
        result.attenuation = albedo;
        return true;
    }
}

unittest
{
    import lib.core.math : fequals;

    // Test Lambertian creation
    auto mat = new Lambertian(Vec3(0.5f, 0.5f, 0.5f));
    assert(mat !is null);

    // Test scatter always returns true (diffuse never absorbs)
    RNG rng = RNG(12345);
    HitInfo hitInfo;
    hitInfo.point = Vec3(0, 0, 0);
    hitInfo.normal = Vec3(0, 1, 0);
    hitInfo.frontFace = true;

    ScatterResult result;
    Ray incomingRay = Ray(Vec3(0, 1, 0), Vec3(0, -1, 0));
    bool scattered = mat.scatter(incomingRay, hitInfo, rng, result);

    assert(scattered == true);
    assert(fequals(result.attenuation.x, 0.5f));
    assert(fequals(result.attenuation.y, 0.5f));
    assert(fequals(result.attenuation.z, 0.5f));

    // Scattered ray should originate from hit point
    assert(result.scattered.origin == hitInfo.point);
}
