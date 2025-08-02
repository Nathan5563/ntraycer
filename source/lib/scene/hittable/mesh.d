module lib.scene.hittable.mesh;

import lib.core.math : Vec2, Vec3, Ray;
import lib.scene.hittable.hittable : Hittable, HitInfo;

private struct Triangle
{
    size_t v1, v2, v3;
    size_t vt1, vt2, vt3;
    size_t vn1, vn2, vn3;
}

class Mesh : Hittable
{
    private Vec3[] vertices;
    private Vec2[] textures;
    private Vec3[] normals;
    private Triangle[] triangles;

    // TODO: constructor, import from obj

    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        return false;
    }
}

// TODO: UNIT TESTS
