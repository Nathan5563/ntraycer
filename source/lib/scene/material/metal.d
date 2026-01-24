// COMPLETE
/**
 * This module implements the Metal (reflective) material which reflects
 * light with optional fuzziness for brushed metal effects.
 */
module lib.scene.material.metal;

import lib.scene.material.material : Material, ScatterResult;
import lib.core.math : Vec3, Ray, RNG;
import lib.scene.hittable.hittable : HitInfo;
import lib.core.math : reflect;

/// @class Metal - A reflective material with optional fuzziness
class Metal : Material
{
    private Vec3 albedo;
    private float fuzz;

    /// @func this - Creates a new Metal material
    ///
    /// @param albedo - the color tint of the reflection
    /// @param fuzz - roughness factor (0 = perfect mirror, 1 = very rough)
    this(Vec3 albedo, float fuzz = 0.0f)
    {
        this.albedo = albedo;
        this.fuzz = fuzz < 1.0f ? fuzz : 1.0f;
    }

    /// @func scatter - Reflects the ray with optional fuzzy perturbation
    override bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const
    {
        Vec3 reflected = reflect(ray.direction.normalized(), hitInfo.normal);

        // Add fuzz for brushed metal effect
        if (fuzz > 0.0f)
        {
            reflected = reflected + fuzz * rng.randomUnitVector();
        }

        result.scattered = Ray(hitInfo.point, reflected);
        result.attenuation = albedo;

        // Only scatter if reflection is in the same hemisphere as normal
        return reflected.dot(hitInfo.normal) > 0;
    }
}

unittest
{
    import lib.core.math : fequals;

    // Test Metal creation with no fuzz
    auto mirror = new Metal(Vec3(0.8f, 0.8f, 0.8f), 0.0f);
    assert(mirror !is null);

    // Test Metal creation with fuzz clamping
    auto roughMetal = new Metal(Vec3(0.8f, 0.6f, 0.2f), 1.5f);
    assert(roughMetal !is null);

    // Test scatter with perfect mirror
    RNG rng = RNG(12345);
    HitInfo hitInfo;
    hitInfo.point = Vec3(0, 0, 0);
    hitInfo.normal = Vec3(0, 1, 0);
    hitInfo.frontFace = true;

    ScatterResult result;
    // Ray coming straight down
    Ray incomingRay = Ray(Vec3(0, 1, 0), Vec3(0, -1, 0));
    bool scattered = mirror.scatter(incomingRay, hitInfo, rng, result);

    assert(scattered == true);
    assert(fequals(result.attenuation.x, 0.8f));
    assert(fequals(result.attenuation.y, 0.8f));
    assert(fequals(result.attenuation.z, 0.8f));

    // Perfect reflection should go straight up
    assert(fequals(result.scattered.direction.x, 0.0f));
    assert(result.scattered.direction.y > 0.0f);
    assert(fequals(result.scattered.direction.z, 0.0f));
}
