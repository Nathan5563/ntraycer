module lib.scene.material.lambertian;

import lib.core.math : Vec3, Ray;
import lib.scene.material.material : Material;
import lib.scene.hittable.hittable : HitInfo;
import lib.core.random : randomUnitVector;

class Lambertian : Material
{
    private Vec3 albedo;

    this(Vec3 albedo)
    {
        this.albedo = albedo;
    }

    bool scatter(
        const Ray ray,
        const HitInfo hitInfo,
        out Vec3 attenuation,
        out Ray scattered
    ) const
    {
        Vec3 scatterDirection = hitInfo.normal + randomUnitVector();
        scattered = Ray(hitInfo.point, scatterDirection);
        attenuation = this.albedo;
        return true;
    }
}

// TODO: UNIT TESTS
