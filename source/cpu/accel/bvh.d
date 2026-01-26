// COMPLETE
/**
 * This module provides a Bounding Volume Hierarchy (BVH) implementation
 * for accelerating ray-scene intersection tests.
 */
module cpu.accel.bvh;

import cpu.accel.aabb : AABB;
import cpu.core.math : Vec3, Ray;
import cpu.scene.hittable.hittable : Hittable, HitInfo;

/// @interface Boundable - Interface for objects that can provide a bounding box
interface Boundable
{
    /// @func boundingBox - Returns the axis-aligned bounding box of this object
    AABB boundingBox() const;
}

/// @class BVHNode - A node in the Bounding Volume Hierarchy tree
class BVHNode : Hittable
{
    private AABB box;
    private Hittable left;
    private Hittable right;
    private Hittable primitive;

    /// @func this - Constructs a BVH from an array of hittable objects
    ///
    /// @param objects - array of hittable objects to build the BVH from
    this(Hittable[] objects)
    {
        if (objects.length == 0)
        {
            box = AABB.empty();
            return;
        }

        if (objects.length == 1)
        {
            primitive = objects[0];
            Boundable b = cast(Boundable) objects[0];
            if (b !is null)
                box = b.boundingBox();
            else
                box = AABB(Vec3(-float.max, -float.max, -float.max), 
                          Vec3(float.max, float.max, float.max));
            return;
        }

        box = AABB.empty();
        foreach (obj; objects)
        {
            Boundable b = cast(Boundable) obj;
            if (b !is null)
                box = box.merge(b.boundingBox());
        }

        int axis = box.longestAxis();
        Hittable[] sorted = sortByAxis(objects, axis);
        size_t mid = sorted.length / 2;

        left = new BVHNode(sorted[0 .. mid]);
        right = new BVHNode(sorted[mid .. $]);
    }

    /// @func sortByAxis - Sorts objects by bounding box centroid along axis
    ///
    /// @param objects - array of hittable objects to sort
    /// @param axis - axis to sort along (0=x, 1=y, 2=z)
    private static Hittable[] sortByAxis(Hittable[] objects, int axis)
    {
        Hittable[] result = new Hittable[objects.length];
        foreach (i, obj; objects)
            result[i] = obj;

        for (size_t i = 1; i < result.length; i++)
        {
            Hittable key = result[i];
            float keyVal = getCentroidAxis(key, axis);
            
            size_t j = i;
            while (j > 0 && getCentroidAxis(result[j - 1], axis) > keyVal)
            {
                result[j] = result[j - 1];
                j--;
            }
            result[j] = key;
        }

        return result;
    }

    /// @func getCentroidAxis - Gets the centroid of an object along a specific axis
    ///
    /// @param obj - the hittable object
    /// @param axis - axis to get centroid for (0=x, 1=y, 2=z)
    private static float getCentroidAxis(Hittable obj, int axis)
    {
        Boundable b = cast(Boundable) obj;
        if (b is null)
            return 0.0f;

        Vec3 centroid = b.boundingBox().centroid();
        if (axis == 0)
            return centroid.x;
        else if (axis == 1)
            return centroid.y;
        else
            return centroid.z;
    }

    /// @func boundingBox - Returns the bounding box of this BVH node
    AABB boundingBox() const
    {
        return box;
    }

    /// @func getLeft - Returns the left child node (for GPU export)
    BVHNode getLeft() const
    {
        return cast(BVHNode) left;
    }

    /// @func getRight - Returns the right child node (for GPU export)
    BVHNode getRight() const
    {
        return cast(BVHNode) right;
    }

    /// @func getPrimitive - Returns the primitive if this is a leaf node (for GPU export)
    Hittable getPrimitive() const
    {
        return cast(Hittable) primitive;
    }

    /// @func isLeaf - Returns true if this is a leaf node
    bool isLeaf() const
    {
        return primitive !is null;
    }

    /// @func hit - Tests if a ray hits any object in this BVH subtree
    ///
    /// @param r - the ray to test
    /// @param timeMin - minimum t value for valid hits
    /// @param timeMax - maximum t value for valid hits
    /// @param hitInfo - output hit information if a hit is found
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        if (!box.hit(r, timeMin, timeMax))
            return false;

        if (primitive !is null)
            return primitive.hit(r, timeMin, timeMax, hitInfo);

        HitInfo leftHit, rightHit;
        bool hitLeft = left !is null && left.hit(r, timeMin, timeMax, leftHit);
        bool hitRight = right !is null && right.hit(r, timeMin, hitLeft ? leftHit.time : timeMax, rightHit);

        if (hitRight)
        {
            hitInfo = rightHit;
            return true;
        }
        else if (hitLeft)
        {
            hitInfo = leftHit;
            return true;
        }

        return false;
    }
}

/// @class BVHAccelerator - A scene accelerated with a BVH
class BVHAccelerator : Hittable
{
    private BVHNode root;

    /// @func this - Constructs a BVH accelerator from an array of objects
    ///
    /// @param objects - the hittable objects to accelerate
    this(Hittable[] objects)
    {
        root = new BVHNode(objects);
    }

    /// @func hit - Tests if a ray hits any object in the accelerated scene
    ///
    /// @param r - the ray to test
    /// @param timeMin - minimum t value for valid hits
    /// @param timeMax - maximum t value for valid hits
    /// @param hitInfo - output hit information if a hit is found
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        if (root is null)
            return false;
        return root.hit(r, timeMin, timeMax, hitInfo);
    }

    /// @func getRoot - Returns the root BVH node (for GPU export)
    BVHNode getRoot() const
    {
        return cast(BVHNode) root;
    }
}

unittest
{
    import cpu.core.math : fequals;

    // Test empty BVH
    BVHAccelerator emptyBVH = new BVHAccelerator([]);
    HitInfo hitInfo;
    Ray ray = Ray(Vec3(0, 0, -5), Vec3(0, 0, 1));
    assert(emptyBVH.hit(ray, 0.001f, float.max, hitInfo) == false);
}
