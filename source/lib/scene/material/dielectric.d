module lib.scene.material.dielectric;

import lib.core.math : Vec3, Ray, reflect, refract, min, sqrt, pow;
import lib.scene.material.material : Material;
import lib.scene.hittable.hittable : HitInfo;
import lib.core.random : randf;

class Dielectric : Material
{
    private float refIdx;

    this(float refIdx)
    {
        this.refIdx = refIdx;
    }

    float reflectance(float cosine, float refIndex) const
    {
        float r0 = (1.0f - refIndex) / (1.0f + refIndex);
        r0 = r0 * r0;
        return r0 + (1.0f - r0) * pow(1.0f - cosine, 5);
    }

    bool scatter(
        const Ray ray,
        const HitInfo hitInfo,
        out Vec3 attenuation,
        out Ray scattered
    ) const
    {
        attenuation = Vec3(1.0f, 1.0f, 1.0f);
        float refractionRatio = hitInfo.frontFace ? (1.0f / refIdx) : refIdx;

        Vec3 unitDirection = ray.direction.normalized();
        float cosTheta = min((-unitDirection).dot(hitInfo.normal), 1.0f);
        float sinTheta = sqrt(1.0f - cosTheta * cosTheta);
        bool cannotRefract = refractionRatio * sinTheta > 1.0f;
        Vec3 direction;
        if (cannotRefract || reflectance(cosTheta, refractionRatio) > randf())
        {
            direction = reflect(unitDirection, hitInfo.normal);
        }
        else
        {
            direction = refract(unitDirection, hitInfo.normal, refractionRatio);
        }
        scattered = Ray(hitInfo.point, direction);
        return true;
    }
}

// TODO: UNIT TESTS
