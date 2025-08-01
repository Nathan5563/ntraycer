module lib.geom.mesh;

import lib.math.vec : Vec3, Vec2;
import lib.math.ray : Ray;
import lib.geom.hittable : Hittable, HitInfo;

struct Triangle
{
    size_t v1, v2, v3;
    size_t vt1, vt2, vt3;
    size_t vn1, vn2, vn3;
}

class Mesh : Hittable
{
    Vec3[] vertices;
    Vec2[] textures;
    Vec3[] normals;
    Triangle[] triangles;

    // TODO: constructor? import from obj

    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo)
    {
        return false;
    }
}

// TODO: UNIT TESTS
