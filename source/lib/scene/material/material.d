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
    /// @prop weight - throughput weight: f(wo,wi) * |n·wi| / pdf
    Vec3 weight;
    /// @prop pdf - probability density in solid angle for the sampled direction
    float pdf;
    /// @prop isSpecular - true if this is a delta/specular bounce (pdf is infinite)
    bool isSpecular;
}

/// @interface Material - Interface for material types that determine surface appearance
interface Material
{
    /// @func scatter - Samples a scattered direction from the BSDF
    ///
    /// @param ray - the incoming ray
    /// @param hitInfo - information about the hit point
    /// @param rng - random number generator for stochastic scattering
    /// @param result - output scatter result (ray + weight + pdf + isSpecular)
    ///
    /// @returns - true if the ray scattered, false if absorbed
    bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const;

    /// @func eval - Evaluates the BSDF for given incoming/outgoing directions
    ///
    /// @param wo - outgoing direction (toward camera/previous vertex)
    /// @param wi - incoming direction (toward light/next vertex)
    /// @param hitInfo - information about the hit point
    ///
    /// @returns - BSDF value f(wo, wi)
    Vec3 eval(const Vec3 wo, const Vec3 wi, const HitInfo hitInfo) const;

    /// @func pdf - Returns the PDF for sampling direction wi given wo
    ///
    /// @param wo - outgoing direction
    /// @param wi - incoming direction
    /// @param hitInfo - information about the hit point
    ///
    /// @returns - probability density in solid angle
    float pdf(const Vec3 wo, const Vec3 wi, const HitInfo hitInfo) const;

    /// @func isSpecular - Returns true if this material has a delta BSDF
    bool isSpecular() const;
}
