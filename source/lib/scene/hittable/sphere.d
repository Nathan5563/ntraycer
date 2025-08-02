module lib.scene.hittable.sphere;

import lib.core.math : Vec3, Ray, sqrt;
import lib.scene.hittable.hittable : Hittable, HitInfo;
import lib.scene.material.material : Material;

class Sphere : Hittable
{
    private Vec3 center;
    private float radius;
    // private Material material;

    this(Vec3 center, float radius)
    {
        this.center = center;
        this.radius = radius;
        // this.material = material;
    }

    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        Vec3 oc = r.origin - center;

        const float a = r.direction.dot(r.direction);
        const float b = 2.0f * oc.dot(r.direction);
        const float c = oc.dot(oc) - radius * radius;
        float discriminant = b * b - 4 * a * c;

        if (discriminant > 0)
        {
            const float sqrtDiscriminant = sqrt(discriminant);

            float r1 = (-b - sqrtDiscriminant) / (2.0f * a);
            if (r1 < timeMax && r1 > timeMin)
            {
                hitInfo.time = r1;
                hitInfo.point = r.at(r1);
                Vec3 outwardNormal = (hitInfo.point - center) / radius;
                hitInfo.setFaceNormal(r, outwardNormal);
                // hitInfo.material = material;
                return true;
            }

            float r2 = (-b + sqrtDiscriminant) / (2.0f * a);
            if (r2 < timeMax && r2 > timeMin)
            {
                hitInfo.time = r2;
                hitInfo.point = r.at(r2);
                Vec3 outwardNormal = (hitInfo.point - center) / radius;
                hitInfo.setFaceNormal(r, outwardNormal);
                // hitInfo.material = material;
                return true;
            }
        }

        return false;
    }
}

// TODO: UNIT TESTS
