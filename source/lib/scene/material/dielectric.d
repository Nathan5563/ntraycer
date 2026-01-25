// COMPLETE
/**
 * This module implements the Dielectric (glass) material which
 * refracts or reflects light based on Snell's law and Fresnel equations.
 */
module lib.scene.material.dielectric;

import lib.scene.material.material : Material, ScatterResult;
import lib.core.math : Vec3, Ray, RNG, sqrt;
import lib.scene.hittable.hittable : HitInfo;
import lib.core.math : refract, reflect;

/// @class Dielectric - A transparent material like glass or water
class Dielectric : Material
{
    private float refIdx;

    /// @func this - Creates a new Dielectric material
    ///
    /// @param refIdx - the refractive index (e.g., 1.5 for glass, 1.33 for water)
    this(float refIdx)
    {
        this.refIdx = refIdx;
    }

    /// @func scatter - Refracts or reflects the ray based on angle and material properties
    override bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const
    {
        // Glass doesn't absorb, weight = 1
        result.weight = Vec3(1.0f, 1.0f, 1.0f);
        result.pdf = 1.0f;  // Delta BSDF placeholder
        result.isSpecular = true;

        float refractionRatio = hitInfo.frontFace ? (1.0f / refIdx) : refIdx;

        Vec3 unitDirection = ray.direction.normalized();
        float cosTheta = (-unitDirection).dot(hitInfo.normal);
        if (cosTheta > 1.0f) cosTheta = 1.0f;
        float sinTheta = sqrt(1.0f - cosTheta * cosTheta);

        bool cannotRefract = refractionRatio * sinTheta > 1.0f;
        Vec3 direction;

        if (cannotRefract || reflectance(cosTheta, refractionRatio) > rng.nextFloat())
        {
            direction = reflect(unitDirection, hitInfo.normal);
        }
        else
        {
            Vec3 refracted;
            refract(unitDirection, hitInfo.normal, refractionRatio, refracted);
            direction = refracted;
        }

        result.scattered = Ray(hitInfo.point, direction.normalized());
        return true;
    }

    /// @func eval - Dielectric is a delta BSDF, returns 0 for non-specular eval
    override Vec3 eval(const Vec3 wo, const Vec3 wi, const HitInfo hitInfo) const
    {
        // Delta distribution - eval is 0 everywhere except exact refract/reflect direction
        return Vec3(0, 0, 0);
    }

    /// @func pdf - Delta BSDF has 0 pdf for any finite direction
    override float pdf(const Vec3 wo, const Vec3 wi, const HitInfo hitInfo) const
    {
        return 0.0f;
    }

    /// @func isSpecular - Dielectric is always specular
    override bool isSpecular() const
    {
        return true;
    }

    /// @func reflectance - Schlick's approximation for Fresnel reflectance
    private static float reflectance(float cosine, float refIdx)
    {
        float r0 = (1 - refIdx) / (1 + refIdx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * pow5(1 - cosine);
    }

    /// @func pow5 - Computes x^5 efficiently
    private static float pow5(float x)
    {
        float x2 = x * x;
        return x2 * x2 * x;
    }
}

unittest
{
    import lib.core.math : fequals;

    // Test Dielectric creation
    auto glass = new Dielectric(1.5f);
    assert(glass !is null);

    // Test scatter always returns true (glass doesn't absorb)
    RNG rng = RNG(12345);
    HitInfo hitInfo;
    hitInfo.point = Vec3(0, 0, 0);
    hitInfo.normal = Vec3(0, 1, 0);
    hitInfo.frontFace = true;

    ScatterResult result;
    Ray incomingRay = Ray(Vec3(0, 1, 0), Vec3(0, -1, 0));
    bool scattered = glass.scatter(incomingRay, hitInfo, rng, result);

    assert(scattered == true);
    // Glass has white attenuation (doesn't absorb light)
    assert(fequals(result.attenuation.x, 1.0f));
    assert(fequals(result.attenuation.y, 1.0f));
    assert(fequals(result.attenuation.z, 1.0f));

    // Test Schlick's approximation at normal incidence
    float r0 = Dielectric.reflectance(1.0f, 1.5f);
    assert(r0 >= 0.0f && r0 <= 1.0f);

    // Test pow5
    assert(fequals(Dielectric.pow5(2.0f), 32.0f));
    assert(fequals(Dielectric.pow5(0.0f), 0.0f));
    assert(fequals(Dielectric.pow5(1.0f), 1.0f));
}
