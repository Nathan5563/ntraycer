// COMPLETE
/**
 * This module implements the Lambertian (diffuse) material which scatters
 * light uniformly in all directions from the surface normal.
 */
module lib.scene.material.lambertian;

import lib.core.math : Vec3, Ray, RNG, PI, max, abs;
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

    /// @func scatter - Scatters the ray with cosine-weighted hemisphere sampling
    override bool scatter(const Ray ray, const HitInfo hitInfo, ref RNG rng, out ScatterResult result) const
    {
        // Cosine-weighted hemisphere sampling: n + randomUnitVector
        Vec3 scatterDirection = hitInfo.normal + rng.randomUnitVector();

        // Catch degenerate scatter direction
        const float lenSq = scatterDirection.x * scatterDirection.x +
                            scatterDirection.y * scatterDirection.y +
                            scatterDirection.z * scatterDirection.z;
        if (lenSq < 1e-8f)
        {
            scatterDirection = hitInfo.normal;
        }

        Vec3 wi = scatterDirection.normalized();
        float cosTheta = abs(hitInfo.normal.dot(wi));

        // PDF for cosine-weighted sampling: cos(theta) / PI
        result.pdf = cosTheta / PI;
        if (result.pdf < 1e-8f)
            result.pdf = 1e-8f;

        // BRDF: albedo / PI
        // Weight = f * cos / pdf = (albedo/PI) * cos / (cos/PI) = albedo
        result.weight = albedo;
        result.scattered = Ray(hitInfo.point, wi);
        result.isSpecular = false;
        return true;
    }

    /// @func eval - Evaluates the Lambertian BRDF (albedo / PI)
    override Vec3 eval(const Vec3 wo, const Vec3 wi, const HitInfo hitInfo) const
    {
        float cosTheta = hitInfo.normal.dot(wi);
        if (cosTheta <= 0.0f)
            return Vec3(0, 0, 0);
        return albedo / PI;
    }

    /// @func pdf - Returns the PDF for cosine-weighted hemisphere sampling
    override float pdf(const Vec3 wo, const Vec3 wi, const HitInfo hitInfo) const
    {
        float cosTheta = hitInfo.normal.dot(wi);
        if (cosTheta <= 0.0f)
            return 0.0f;
        return cosTheta / PI;
    }

    /// @func isSpecular - Lambertian is not specular
    override bool isSpecular() const
    {
        return false;
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
