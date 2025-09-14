module lib.scene.material.metal;

import lib.core.math : Vec3, Ray, reflect;
import lib.scene.material.material : Material;
import lib.scene.hittable.hittable : HitInfo;
import lib.core.random : randomInUnitSphere;

class Metal : Material
{
    private Vec3 albedo;
    private float fuzz;

    this(Vec3 albedo, float fuzz)
    {
        this.albedo = albedo;
        this.fuzz = fuzz < 1.0f ? fuzz : 1.0f;
    }

    bool scatter(
        const Ray ray,
        const HitInfo hitInfo,
        out Vec3 attenuation,
        out Ray scattered
    ) const
    {
        Vec3 reflected = reflect(ray.direction.normalized(), hitInfo.normal);
        scattered = Ray(hitInfo.point, reflected + fuzz * randomInUnitSphere());
        attenuation = this.albedo;
        return scattered.direction.dot(hitInfo.normal) > 0;
    }
}

// TODO: UNIT TESTS
