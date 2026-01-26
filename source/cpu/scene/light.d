// COMPLETE
/**
 * This module defines the Light interface and light sampling utilities
 * for Next Event Estimation (direct light sampling).
 */
module cpu.scene.light;

import cpu.core.math : Vec3, Ray, RNG;
import cpu.scene.hittable.hittable : Hittable, HitInfo;

/// @struct LightSample - Result of sampling a point on a light source
struct LightSample
{
    Vec3 point;      /// sampled point on the light
    Vec3 normal;     /// normal at the sampled point
    Vec3 emission;   /// emission color of the light
    float pdfArea;   /// probability density in area measure (1/area for uniform)
    float area;      /// total area of the light (for MIS pdf conversion)
}

/// @interface Light - Interface for objects that emit light and can be sampled
interface Light
{
    /// @func sampleLight - Samples a random point on the light
    ///
    /// @param hitPoint - the point being illuminated
    /// @param rng - random number generator
    LightSample sampleLight(Vec3 hitPoint, ref RNG rng) const;

    /// @func getEmission - Returns the emission color of the light
    Vec3 getEmission() const;

    /// @func getArea - Returns the surface area of the light
    float getArea() const;

    /// @func getPdfArea - Returns the area PDF for a point on this light (1/area for uniform)
    float getPdfArea() const;
}
