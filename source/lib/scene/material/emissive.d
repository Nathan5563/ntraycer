// COMPLETE
/**
 * This module implements the Emissive material which emits light.
 * Used for area lights.
 */
module lib.scene.material.emissive;

import lib.scene.material.material : Material, ScatterResult;
import lib.core.math : Vec3, Ray, RNG;
import lib.scene.hittable.hittable : HitInfo;

/// @class Emissive - A light-emitting material
class Emissive : Material
{
    private Vec3 emitColor;
    private float intensity;

    /// @func this - Creates an emissive material
    ///
    /// @param emitColor - the color of the emitted light
    /// @param intensity - the brightness multiplier (default 1.0)
    this(Vec3 emitColor, float intensity = 1.0f)
    {
        this.emitColor = emitColor;
        this.intensity = intensity;
    }

    /// @func scatter - Emissive materials don't scatter, they emit
    override bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const
    {
        // Return the emission color as attenuation, but don't scatter
        // The renderer will use this as the final color
        result.attenuation = emitColor * intensity;
        return false;  // No scattering, light terminates here
    }

    /// @func emit - Returns the emitted light color
    ///
    /// @returns - the emission color multiplied by intensity
    Vec3 emit() const
    {
        return emitColor * intensity;
    }
}

unittest
{
    import lib.core.math : fequals;

    // Test Emissive creation
    auto light = new Emissive(Vec3(1, 1, 1), 10.0f);
    assert(light !is null);

    // Test emit
    Vec3 emission = light.emit();
    assert(fequals(emission.x, 10.0f));
    assert(fequals(emission.y, 10.0f));
    assert(fequals(emission.z, 10.0f));

    // Test scatter returns false (light doesn't scatter)
    RNG rng = RNG(12345);
    HitInfo hitInfo;
    hitInfo.point = Vec3(0, 0, 0);
    hitInfo.normal = Vec3(0, 1, 0);

    ScatterResult result;
    Ray incomingRay = Ray(Vec3(0, 1, 0), Vec3(0, -1, 0));
    bool scattered = light.scatter(incomingRay, hitInfo, rng, result);

    assert(scattered == false);
    assert(fequals(result.attenuation.x, 10.0f));
}
