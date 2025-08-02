module lib.scene.material.material;

import lib.core.math : Vec3, Ray;
import lib.scene.hittable.hittable : HitInfo;

interface Material
{
    Vec3 shade(const Ray ray, const HitInfo hitInfo) const;
}
