module lib.scene.material.material;

import lib.core.math : Vec3, Ray;
import lib.scene.hittable.hittable : HitInfo;

interface Material
{
    bool scatter(
        const Ray ray,
        const HitInfo hitInfo,
        out Vec3 attenuation,
        out Ray scattered
    ) const;
}
