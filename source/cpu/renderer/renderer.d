// COMPLETE
/**
 * This module implements the path tracing Renderer which renders a scene
 * by tracing rays and accumulating color samples for each pixel.
 */
module cpu.renderer.renderer;

import cpu.core.math : Vec2, Vec3, Ray, RNG, clamp, sqrt, max, abs, PI;
import cpu.scene.scene : Scene;
import cpu.scene.hittable.hittable : Hittable, HitInfo;
import cpu.scene.light : LightSample;
import cpu.scene.material.material : Material, ScatterResult;
import cpu.scene.material.emissive : Emissive;
import cpu.renderer.film : Film, Pixel;

/// @class Renderer - Path tracing renderer with Next Event Estimation
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

    /// @func rayColor - Traces a ray through the scene
    ///
    /// @param ray - the ray to trace
    /// @param scene - the scene to trace against
    /// @param depth - remaining recursion depth
    /// @param rng - random number generator
    private Vec3 rayColor(Ray ray, ref const Scene scene, int depth, ref RNG rng) const
    {
        Vec3 throughput = Vec3(1.0f, 1.0f, 1.0f);
        Vec3 radiance = Vec3(0.0f, 0.0f, 0.0f);
        Ray currentRay = ray;
        bool lastBounceSpecular = true;

        for (int bounce = 0; bounce < depth; bounce++)
        {
            // Check if we hit the background
            HitInfo hitInfo;
            if (!scene.hit(currentRay, 0.001f, float.infinity, hitInfo))
            {
                Vec3 bg = scene.background.sample(currentRay);
                radiance = radiance + throughput.mul(bg);
                break;
            }

            // Check if we hit a light
            Emissive emissive = cast(Emissive) hitInfo.material;
            if (emissive !is null)
            {
                // Add emission on first bounce or after specular bounces
                if (bounce == 0 || lastBounceSpecular)
                {
                    radiance = radiance + throughput.mul(emissive.emit());
                }
                break;
            }

            Material mat = hitInfo.material;
            Vec3 wo = (currentRay.direction * -1.0f).normalized();

            // NEE with MIS for non-specular materials
            if (scene.hasLights() && !mat.isSpecular())
            {
                LightSample lightSample;
                if (scene.sampleLight(hitInfo.point, rng, lightSample))
                {
                    Vec3 toLight = lightSample.point - hitInfo.point;
                    float dist = toLight.norm();
                    Vec3 wi = toLight / dist;

                    float cosTheta = hitInfo.normal.dot(wi);
                    float cosLight = abs(lightSample.normal.dot(wi * -1.0f));

                    if (cosTheta > 0.0f && cosLight > 0.0f)
                    {
                        // Shadow ray
                        Ray shadowRay = Ray(hitInfo.point + hitInfo.normal * 0.001f, wi);
                        HitInfo shadowHit;
                        bool inShadow = scene.hit(shadowRay, 0.001f, dist - 0.001f, shadowHit);

                        if (!inShadow)
                        {
                            // Convert area PDF to solid angle PDF
                            float pLightOmega = lightSample.pdfArea * dist * dist / cosLight;

                            // Get BSDF pdf for this direction
                            float pBsdf = mat.pdf(wo, wi, hitInfo);

                            // MIS weight using power heuristic
                            float misWeight = powerHeuristic(pLightOmega, pBsdf);

                            // BSDF evaluation
                            Vec3 brdf = mat.eval(wo, wi, hitInfo);

                            // Direct light contribution
                            Vec3 directLight = lightSample.emission.mul(brdf) * cosTheta * misWeight / pLightOmega;
                            radiance = radiance + throughput.mul(directLight);
                        }
                    }
                }
            }

            // Sample BSDF for continuation
            ScatterResult scatterResult;
            if (!mat.scatter(currentRay, hitInfo, rng, scatterResult))
            {
                break;
            }

            // Continue path
            throughput = throughput.mul(scatterResult.weight);
            currentRay = scatterResult.scattered;
            lastBounceSpecular = scatterResult.isSpecular;

            // Russian roulette with clamped probability
            if (bounce > 5)
            {
                float p = clamp(max(throughput.x, max(throughput.y, throughput.z)), 0.0f, 0.99f);
                if (rng.nextFloat() > p)
                    break;
                throughput = throughput / p;
            }
        }

        return radiance;
    }

    /// @func powerHeuristic - Computes the power heuristic MIS weight
    ///
    /// @param pdfA - first PDF
    /// @param pdfB - second PDF
    private float powerHeuristic(float pdfA, float pdfB) const
    {
        float a2 = pdfA * pdfA;
        float b2 = pdfB * pdfB;
        if (a2 + b2 < 1e-10f)
            return 0.0f;
        return a2 / (a2 + b2);
    }
}

unittest
{
    import cpu.core.math : fequals;

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
