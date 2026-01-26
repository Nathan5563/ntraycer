// COMPLETE
/**
 * This module provides an Axis-Aligned Bounding Box (AABB) implementation
 * for use in spatial acceleration structures like BVH.
 */
module cpu.accel.aabb;

import cpu.core.math : Vec3, Ray, min, max;

/// @struct AABB - Axis-Aligned Bounding Box for spatial acceleration
struct AABB
{
    Vec3 minPoint;
    Vec3 maxPoint;

    /// @func this - Constructs an AABB from two corner points
    ///
    /// @param minP - the minimum corner (smallest x, y, z values)
    /// @param maxP - the maximum corner (largest x, y, z values)
    this(Vec3 minP, Vec3 maxP)
    {
        this.minPoint = minP;
        this.maxPoint = maxP;
    }

    /// @func empty - Creates an empty (invalid) AABB where min > max
    static AABB empty()
    {
        return AABB(
            Vec3(float.max, float.max, float.max),
            Vec3(-float.max, -float.max, -float.max)
        );
    }

    /// @func fromPoint - Creates an AABB containing a single point
    ///
    /// @param point - the point to enclose
    static AABB fromPoint(Vec3 point)
    {
        return AABB(point, point);
    }

    /// @func hit - Tests ray-box intersection using the slab method
    ///
    /// @param ray - the ray to test
    /// @param tMin - minimum t value for valid hits
    /// @param tMax - maximum t value for valid hits
    bool hit(Ray ray, float tMin, float tMax) const
    {
        // X axis slab
        float invD = 1.0f / ray.direction.x;
        float t0 = (minPoint.x - ray.origin.x) * invD;
        float t1 = (maxPoint.x - ray.origin.x) * invD;
        if (invD < 0.0f)
        {
            float temp = t0;
            t0 = t1;
            t1 = temp;
        }
        tMin = t0 > tMin ? t0 : tMin;
        tMax = t1 < tMax ? t1 : tMax;
        if (tMax <= tMin)
            return false;

        // Y axis slab
        invD = 1.0f / ray.direction.y;
        t0 = (minPoint.y - ray.origin.y) * invD;
        t1 = (maxPoint.y - ray.origin.y) * invD;
        if (invD < 0.0f)
        {
            float temp = t0;
            t0 = t1;
            t1 = temp;
        }
        tMin = t0 > tMin ? t0 : tMin;
        tMax = t1 < tMax ? t1 : tMax;
        if (tMax <= tMin)
            return false;

        // Z axis slab
        invD = 1.0f / ray.direction.z;
        t0 = (minPoint.z - ray.origin.z) * invD;
        t1 = (maxPoint.z - ray.origin.z) * invD;
        if (invD < 0.0f)
        {
            float temp = t0;
            t0 = t1;
            t1 = temp;
        }
        tMin = t0 > tMin ? t0 : tMin;
        tMax = t1 < tMax ? t1 : tMax;
        if (tMax <= tMin)
            return false;

        return true;
    }

    /// @func merge - Computes the union of two AABBs
    ///
    /// @param other - the other AABB to merge with
    AABB merge(AABB other) const
    {
        return AABB(
            Vec3(
                min(minPoint.x, other.minPoint.x),
                min(minPoint.y, other.minPoint.y),
                min(minPoint.z, other.minPoint.z)
            ),
            Vec3(
                max(maxPoint.x, other.maxPoint.x),
                max(maxPoint.y, other.maxPoint.y),
                max(maxPoint.z, other.maxPoint.z)
            )
        );
    }

    /// @func expandToInclude - Expands this AABB to include a point
    ///
    /// @param point - the point to include
    AABB expandToInclude(Vec3 point) const
    {
        return AABB(
            Vec3(
                min(minPoint.x, point.x),
                min(minPoint.y, point.y),
                min(minPoint.z, point.z)
            ),
            Vec3(
                max(maxPoint.x, point.x),
                max(maxPoint.y, point.y),
                max(maxPoint.z, point.z)
            )
        );
    }

    /// @func centroid - Returns the center point of this AABB
    Vec3 centroid() const
    {
        return (minPoint + maxPoint) * 0.5f;
    }

    /// @func size - Returns the size (extent) along each axis
    Vec3 size() const
    {
        return maxPoint - minPoint;
    }

    /// @func surfaceArea - Returns the surface area (for SAH heuristic)
    float surfaceArea() const
    {
        Vec3 d = size();
        return 2.0f * (d.x * d.y + d.y * d.z + d.z * d.x);
    }

    /// @func longestAxis - Returns index of longest axis (0=x, 1=y, 2=z)
    int longestAxis() const
    {
        Vec3 d = size();
        if (d.x > d.y && d.x > d.z)
            return 0;
        else if (d.y > d.z)
            return 1;
        else
            return 2;
    }
}

unittest
{
    import cpu.core.math : fequals;

    // Test AABB construction
    AABB box = AABB(Vec3(-1, -2, -3), Vec3(1, 2, 3));
    assert(box.minPoint.x == -1);
    assert(box.maxPoint.z == 3);

    // Test empty AABB
    AABB empty = AABB.empty();
    assert(empty.minPoint.x == float.max);
    assert(empty.maxPoint.x == -float.max);

    // Test fromPoint
    AABB point = AABB.fromPoint(Vec3(5, 5, 5));
    assert(point.minPoint == point.maxPoint);
    assert(point.minPoint.x == 5);

    // Test centroid
    Vec3 center = box.centroid();
    assert(fequals(center.x, 0));
    assert(fequals(center.y, 0));
    assert(fequals(center.z, 0));

    // Test size
    Vec3 sz = box.size();
    assert(fequals(sz.x, 2));
    assert(fequals(sz.y, 4));
    assert(fequals(sz.z, 6));

    // Test longestAxis
    assert(box.longestAxis() == 2);  // Z is longest (6)

    // Test merge
    AABB box2 = AABB(Vec3(0, 0, 0), Vec3(5, 5, 5));
    AABB merged = box.merge(box2);
    assert(merged.minPoint.x == -1);
    assert(merged.maxPoint.x == 5);

    // Test expandToInclude
    AABB expanded = box.expandToInclude(Vec3(10, 10, 10));
    assert(expanded.maxPoint.x == 10);
    assert(expanded.minPoint.x == -1);

    // Test ray hit - ray through center
    Ray ray = Ray(Vec3(0, 0, -10), Vec3(0, 0, 1));
    assert(box.hit(ray, 0.0f, float.max) == true);

    // Test ray miss
    Ray missRay = Ray(Vec3(10, 10, -10), Vec3(0, 0, 1));
    assert(box.hit(missRay, 0.0f, float.max) == false);

    // Test ray hit from inside
    Ray insideRay = Ray(Vec3(0, 0, 0), Vec3(1, 0, 0));
    assert(box.hit(insideRay, 0.0f, float.max) == true);

    // Test surface area
    AABB unitBox = AABB(Vec3(0, 0, 0), Vec3(1, 1, 1));
    assert(fequals(unitBox.surfaceArea(), 6.0f));
}
