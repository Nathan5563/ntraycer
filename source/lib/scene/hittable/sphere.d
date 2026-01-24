// COMPLETE
/**
 * This module implements the Sphere geometric primitive, one of the most
 * common objects used in ray tracing scenes.
 */
module lib.scene.hittable.sphere;

import lib.accel.aabb : AABB;
import lib.accel.bvh : Boundable;
import lib.core.math : Vec3, Ray, sqrt;
import lib.scene.hittable.hittable : Hittable, HitInfo;
import lib.scene.material.material : Material;

/// @class Sphere - A sphere defined by center point and radius
class Sphere : Hittable, Boundable
{
    private Vec3 center;
    private float radius;
    private Material material;

    /// @func this - Creates a new Sphere
    ///
    /// @param center - the center point of the sphere
    /// @param radius - the radius of the sphere
    /// @param material - the material applied to the sphere surface
    this(Vec3 center, float radius, Material material)
    {
        this.center = center;
        this.radius = radius;
        this.material = material;
    }

    /// @func hit - Tests ray-sphere intersection using the quadratic formula
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
                hitInfo.material = cast(Material) material;
                return true;
            }

            float r2 = (-b + sqrtDiscriminant) / (2.0f * a);
            if (r2 < timeMax && r2 > timeMin)
            {
                hitInfo.time = r2;
                hitInfo.point = r.at(r2);
                Vec3 outwardNormal = (hitInfo.point - center) / radius;
                hitInfo.setFaceNormal(r, outwardNormal);
                hitInfo.material = cast(Material) material;
                return true;
            }
        }

        return false;
    }

    /// @func boundingBox - Returns the axis-aligned bounding box of the sphere
    AABB boundingBox() const
    {
        Vec3 radiusVec = Vec3(radius, radius, radius);
        return AABB(center - radiusVec, center + radiusVec);
    }
}

unittest
{
    import lib.core.math : fequals;
    import lib.scene.material.lambertian : Lambertian;

    // Create a unit sphere at origin
    auto mat = new Lambertian(Vec3(1, 0, 0));
    auto sphere = new Sphere(Vec3(0, 0, 0), 1.0f, mat);

    // Ray from outside pointing at center should hit
    Ray ray = Ray(Vec3(0, 0, -5), Vec3(0, 0, 1));
    HitInfo hitInfo;
    bool hit = sphere.hit(ray, 0.001f, float.infinity, hitInfo);

    assert(hit == true);
    assert(fequals(hitInfo.time, 4.0f));  // Hit at z = -1
    assert(fequals(hitInfo.point.z, -1.0f));
    assert(fequals(hitInfo.normal.z, -1.0f));  // Normal points toward ray
    assert(hitInfo.frontFace == true);

    // Ray missing the sphere should not hit
    Ray missRay = Ray(Vec3(5, 0, -5), Vec3(0, 0, 1));
    bool miss = sphere.hit(missRay, 0.001f, float.infinity, hitInfo);
    assert(miss == false);

    // Ray inside sphere pointing outward
    Ray insideRay = Ray(Vec3(0, 0, 0), Vec3(0, 0, 1));
    bool insideHit = sphere.hit(insideRay, 0.001f, float.infinity, hitInfo);
    assert(insideHit == true);
    assert(fequals(hitInfo.time, 1.0f));
    assert(hitInfo.frontFace == false);  // Hit back face

    // Ray with restricted time range
    Ray rangeRay = Ray(Vec3(0, 0, -5), Vec3(0, 0, 1));
    bool rangeHit = sphere.hit(rangeRay, 0.001f, 3.0f, hitInfo);
    assert(rangeHit == false);  // Hit is at t=4, outside range
}
