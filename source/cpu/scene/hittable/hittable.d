// COMPLETE
/**
 * This module provides the interface for objects that can be hit by rays. It
 * is implemented by geometric primitives which are used to build a scene.
 */
module cpu.scene.hittable.hittable;

import cpu.core.math : Vec3, Ray;
import cpu.scene.material.material : Material;

/// @struct HitInfo - Contains information about a ray-object intersection
struct HitInfo
{
    /// @prop point - the point of intersection
    Vec3 point;
    /// @prop normal - the normal of the surface at the point of intersection
    Vec3 normal;
    /// @prop time - the parameter along the ray where the intersection occurred
    float time;
    /// @prop frontFace - true if the ray hit the front face, false otherwise
    bool frontFace;
    /// @prop material - the material of the object that was hit
    Material material;

    /// @func setFaceNormal - Sets the face's normal depending on ray direction
    /// 
    /// @param r - the ray that hit the object
    /// @param outwardNormal - the outward normal of the face that was hit
    void setFaceNormal(Ray r, Vec3 outwardNormal)
    {
        this.frontFace = r.direction.dot(outwardNormal) < 0;
        if (frontFace)
        {
            this.normal = outwardNormal;
        }
        else
        {
            this.normal = -outwardNormal;
        }
    }
}

/// @interface Hittable - An interface for objects that can be intersected by a ray
interface Hittable
{
    /// @func hit - Checks if a ray hits the object in the given bounds
    ///
    /// @param r - the ray to check
    /// @param timeMin - the lower bound for the ray parameter
    /// @param timeMax - the upper bound for the ray parameter
    /// @param hitInfo - the hit information to fill if the ray hits the object
    ///
    /// @returns - true if the ray hit the object, false otherwise
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const;
}

unittest
{
    import cpu.core.math : fequals;

    // Test HitInfo setFaceNormal with front face hit
    HitInfo hitInfo;
    Ray rayTowardSurface = Ray(Vec3(0, 0, -5), Vec3(0, 0, 1));
    Vec3 outwardNormal = Vec3(0, 0, -1);  // Normal pointing toward ray

    hitInfo.setFaceNormal(rayTowardSurface, outwardNormal);
    assert(hitInfo.frontFace == true);
    assert(hitInfo.normal == outwardNormal);

    // Test HitInfo setFaceNormal with back face hit
    HitInfo hitInfo2;
    Ray rayFromInside = Ray(Vec3(0, 0, 0), Vec3(0, 0, 1));
    Vec3 outwardNormal2 = Vec3(0, 0, 1);  // Normal pointing same direction as ray

    hitInfo2.setFaceNormal(rayFromInside, outwardNormal2);
    assert(hitInfo2.frontFace == false);
    assert(hitInfo2.normal == -outwardNormal2);
}
