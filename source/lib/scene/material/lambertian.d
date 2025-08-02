module lib.scene.material.lambertian;

import lib.core.math : Vec3, Ray, max;
import lib.scene.material.material : Material;
import lib.scene.hittable.hittable : HitInfo;

class Lambertian : Material
{
    private Vec3 albedo;

    this(Vec3 albedo)
    {
        this.albedo = albedo;
    }

    Vec3 shade(const Ray ray, const HitInfo hitInfo) const
    {
        Vec3 L = Vec3(1, 1, 1).normalized();
        float intensity = max(hitInfo.normal.dot(L), 0.0f);
        return this.albedo * intensity;
    }
}

// TODO: UNIT TESTS
