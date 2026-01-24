// COMPLETE
/**
 * This module defines the Material interface and ScatterResult struct used
 * for physically-based material interactions in the ray tracer.
 */
module lib.scene.material.material;

import lib.core.math : Vec3, Ray, RNG;
import lib.scene.hittable.hittable : HitInfo;

/// @struct ScatterResult - Contains the result of a material scatter operation
struct ScatterResult
{
    /// @prop scattered - the scattered ray
    Ray scattered;
    /// @prop attenuation - the color attenuation of the material
    Vec3 attenuation;
}

/// @interface Material - Interface for material types that determine surface appearance
interface Material
{
    /// @func scatter - Determines how a ray scatters off this material
    ///
    /// @param ray - the incoming ray
    /// @param hitInfo - information about the hit point
    /// @param rng - random number generator for stochastic scattering
    /// @param result - output scatter result (ray + attenuation)
    ///
    /// @returns - true if the ray scattered, false if absorbed
    bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const;
}
