// COMPLETE
/**
 * This module provides background/environment implementations for the scene.
 * Backgrounds determine the color returned when a ray doesn't hit any objects.
 */
module lib.scene.background;

import lib.core.math : Vec3, Ray;

/// @interface Background - Interface for scene backgrounds/environments
interface Background
{
    /// @func sample - Get the color for a ray that didn't hit anything
    ///
    /// @param ray - the ray that missed all objects
    ///
    /// @returns - the background color for this ray direction
    Vec3 sample(const Ray ray) const;
}

/// @class SolidBackground - A single solid color background
class SolidBackground : Background
{
    private Vec3 color;

    /// @func this - Creates a solid color background
    ///
    /// @param color - the background color
    this(Vec3 color)
    {
        this.color = color;
    }

    override Vec3 sample(const Ray ray) const
    {
        return color;
    }
}

/// @class GradientBackground - A vertical gradient between two colors
class GradientBackground : Background
{
    private Vec3 bottomColor;
    private Vec3 topColor;

    /// @func this - Creates a vertical gradient background
    ///
    /// @param bottomColor - the color at the bottom (y = -1)
    /// @param topColor - the color at the top (y = +1)
    this(Vec3 bottomColor, Vec3 topColor)
    {
        this.bottomColor = bottomColor;
        this.topColor = topColor;
    }

    override Vec3 sample(const Ray ray) const
    {
        const Vec3 unitDirection = ray.direction.normalized();
        const float t = 0.5f * (unitDirection.y + 1.0f);
        return (1.0f - t) * bottomColor + t * topColor;
    }
}

/// @func skyBackground - Creates a default sky gradient background
///
/// @returns - a gradient from white (horizon) to light blue (zenith)
GradientBackground skyBackground()
{
    return new GradientBackground(Vec3(1.0f, 1.0f, 1.0f), Vec3(0.5f, 0.7f, 1.0f));
}

unittest
{
    import lib.core.math : fequals;

    // Test SolidBackground
    auto solid = new SolidBackground(Vec3(0.5f, 0.5f, 0.5f));
    Ray ray = Ray(Vec3(0, 0, 0), Vec3(1, 0, 0));
    Vec3 color = solid.sample(ray);
    assert(fequals(color.x, 0.5f));
    assert(fequals(color.y, 0.5f));
    assert(fequals(color.z, 0.5f));

    // Solid background returns same color for any ray direction
    Ray ray2 = Ray(Vec3(0, 0, 0), Vec3(0, 1, 0));
    Vec3 color2 = solid.sample(ray2);
    assert(color == color2);

    // Test GradientBackground
    auto gradient = new GradientBackground(Vec3(0, 0, 0), Vec3(1, 1, 1));

    // Ray pointing straight up should return top color
    Ray upRay = Ray(Vec3(0, 0, 0), Vec3(0, 1, 0));
    Vec3 upColor = gradient.sample(upRay);
    assert(fequals(upColor.x, 1.0f));
    assert(fequals(upColor.y, 1.0f));
    assert(fequals(upColor.z, 1.0f));

    // Ray pointing straight down should return bottom color
    Ray downRay = Ray(Vec3(0, 0, 0), Vec3(0, -1, 0));
    Vec3 downColor = gradient.sample(downRay);
    assert(fequals(downColor.x, 0.0f));
    assert(fequals(downColor.y, 0.0f));
    assert(fequals(downColor.z, 0.0f));

    // Ray pointing horizontal should return 50% blend
    Ray horizRay = Ray(Vec3(0, 0, 0), Vec3(1, 0, 0));
    Vec3 horizColor = gradient.sample(horizRay);
    assert(fequals(horizColor.x, 0.5f));
    assert(fequals(horizColor.y, 0.5f));
    assert(fequals(horizColor.z, 0.5f));

    // Test skyBackground factory function
    auto sky = skyBackground();
    assert(sky !is null);
}
