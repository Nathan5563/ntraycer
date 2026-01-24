// TODO: IMPLEMENT
/**
 * This module implements a triangle mesh primitive for rendering complex
 * geometry loaded from external files (e.g., OBJ format).
 */
module lib.scene.hittable.mesh;

import lib.core.math : Vec2, Vec3, Ray, min, max;
import lib.scene.hittable.hittable : Hittable, HitInfo;

/// @struct Triangle - Indices into vertex, texture, and normal arrays
private struct Triangle
{
    size_t v1, v2, v3;
    size_t vt1, vt2, vt3;
    size_t vn1, vn2, vn3;
}

/// @class Mesh - A triangle mesh composed of vertices, normals, and texture coords
class Mesh : Hittable
{
    private Vec3[] vertices;
    private Vec2[] textures;
    private Vec3[] normals;
    private Triangle[] triangles;

    // TODO: constructor, import from obj

    /// @func hit - Tests ray intersection against all triangles in the mesh
    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
    {
        // TODO: implement Möller–Trumbore intersection algorithm
        return false;
    }
}

// TODO: UNIT TESTS
