// COMPLETE
/**
 * This module implements the path tracing Renderer which renders a scene
 * by tracing rays and accumulating color samples for each pixel.
 */
module lib.renderer.renderer;

import lib.core.math : Vec2, Vec3, Ray, RNG, clamp, sqrt, max;
import lib.scene.scene : Scene;
import lib.scene.hittable.hittable : HitInfo;
import lib.scene.material.material : ScatterResult;
import lib.renderer.film : Film, Pixel;

/// @class Renderer - Path tracing renderer for producing images from scenes
class Renderer
{
    /// @prop film - the output image buffer
    Film film;
    /// @prop samplesPerPixel - number of samples for anti-aliasing
    int samplesPerPixel;
    /// @prop maxDepth - maximum ray bounce depth
    int maxDepth;

    /// @func this - Creates a new Renderer
    ///
    /// @param width - image width in pixels
    /// @param height - image height in pixels
    /// @param samplesPerPixel - samples per pixel for anti-aliasing (default 16)
    /// @param maxDepth - maximum ray recursion depth (default 50)
    this(int width, int height, int samplesPerPixel = 16, int maxDepth = 50)
    {
        this.film = new Film(width, height);
        this.samplesPerPixel = samplesPerPixel;
        this.maxDepth = maxDepth;
    }

    /// @func render - Renders the scene to the film
    ///
    /// @param scene - the scene to render
    void render(ref const Scene scene)
    {
        foreach (int y; 0 .. film.height)
        {
            foreach (int x; 0 .. film.width)
            {
                Vec3 colorAccum = Vec3(0.0f, 0.0f, 0.0f);
                RNG rng = RNG(cast(uint)(y * film.width + x + 1));

                foreach (s; 0 .. samplesPerPixel)
                {
                    const float u = (cast(float)(x) + rng.nextFloat()) / (film.width - 1);
                    const float v = (cast(float)(film.height - 1 - y) + rng.nextFloat()) / (film.height - 1);

                    const Ray ray = scene.camera.getRay(Vec2(u, v));
                    const Vec3 color = rayColor(ray, scene, maxDepth, rng);
                    colorAccum = colorAccum + color;
                }

                const float scale = 1.0f / samplesPerPixel;
                const float r = sqrt(clamp(colorAccum.x * scale, 0.0f, 1.0f));
                const float g = sqrt(clamp(colorAccum.y * scale, 0.0f, 1.0f));
                const float b = sqrt(clamp(colorAccum.z * scale, 0.0f, 1.0f));

                film.setPixel(x, y, Pixel(
                    cast(ubyte)(255.99f * r),
                    cast(ubyte)(255.99f * g),
                    cast(ubyte)(255.99f * b)
                ));
            }
        }
    }

    /// @func rayColor - Traces a ray and returns its color contribution
    ///
    /// @param ray - the ray to trace
    /// @param scene - the scene to trace against
    /// @param depth - remaining recursion depth
    /// @param rng - random number generator for stochastic effects
    ///
    /// @returns - the color contribution of this ray
    private Vec3 rayColor(Ray ray, ref const Scene scene, int depth, ref RNG rng) const
    {
        if (depth <= 0)
        {
            return Vec3(0.0f, 0.0f, 0.0f);
        }

        HitInfo hitInfo;
        if (scene.hit(ray, 0.001f, float.infinity, hitInfo))
        {
            ScatterResult scatterResult;
            if (hitInfo.material.scatter(ray, hitInfo, rng, scatterResult))
            {
                Vec3 scattered_color = rayColor(scatterResult.scattered, scene, depth - 1, rng);
                return Vec3(
                    scatterResult.attenuation.x * scattered_color.x,
                    scatterResult.attenuation.y * scattered_color.y,
                    scatterResult.attenuation.z * scattered_color.z
                );
            }
            // Material didn't scatter - return its attenuation as emission
            return scatterResult.attenuation;
        }

        return scene.background.sample(ray);
    }
}

unittest
{
    import lib.core.math : fequals;

    // Test Renderer creation
    auto renderer = new Renderer(100, 50, 4, 10);
    assert(renderer.film !is null);
    assert(renderer.film.width == 100);
    assert(renderer.film.height == 50);
    assert(renderer.samplesPerPixel == 4);
    assert(renderer.maxDepth == 10);

    // Test default parameters
    auto defaultRenderer = new Renderer(800, 600);
    assert(defaultRenderer.samplesPerPixel == 16);
    assert(defaultRenderer.maxDepth == 50);
}
