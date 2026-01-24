// COMPLETE
/**
 * This module implements the PinholeCamera, a simple perspective camera
 * without depth of field effects. It's the standard camera for ray tracing.
 */
module lib.scene.camera.pinhole;

import lib.core.math : Vec2, Vec3, Ray, degToRad, tan, clamp;
import lib.scene.camera.camera : Camera;

/// @class PinholeCamera - A perspective camera with no depth of field
class PinholeCamera : Camera
{
    private Vec3 origin;
    private Vec3 lowerLeft;
    private Vec3 horizontal;
    private Vec3 vertical;

    /// @func this - Creates a new pinhole camera
    ///
    /// @param lookFrom - the camera position in world space
    /// @param lookAt - the point the camera is looking at
    /// @param vup - the up direction vector (usually 0,1,0)
    /// @param vfovDegrees - vertical field of view in degrees
    /// @param aspectRatio - width/height ratio of the image
    this(
        Vec3 lookFrom,
        Vec3 lookAt,
        Vec3 vup,
        float vfovDegrees,
        float aspectRatio
    ) {
        this.origin = lookFrom;

        const float halfHeight = tan(degToRad(vfovDegrees) / 2);
        const float halfWidth = aspectRatio * halfHeight;

        const Vec3 w = (lookFrom - lookAt).normalized();
        const Vec3 u = vup.cross(w).normalized();
        const Vec3 v = w.cross(u);

        this.lowerLeft = origin - halfWidth * u - halfHeight * v - w;
        this.horizontal = 2 * halfWidth * u;
        this.vertical = 2 * halfHeight * v;
    }

    /// @func position - Returns the camera origin
    Vec3 position() const
    {
        return origin;
    }

    /// @func getRay - Generates a ray through the given screen coordinates
    Ray getRay(Vec2 coord) const
    {
        Vec3 direction = lowerLeft +
                         clamp(coord.u, 0.0f, 1.0f) * horizontal +
                         clamp(coord.v, 0.0f, 1.0f) * vertical -
                         origin;
        return Ray(origin, direction);
    }
}

unittest
{
    import lib.core.math : fequals;

    // Create a camera looking down -Z axis
    auto camera = new PinholeCamera(
        Vec3(0, 0, 0),    // lookFrom
        Vec3(0, 0, -1),   // lookAt
        Vec3(0, 1, 0),    // up
        90.0f,            // 90 degree FOV
        2.0f              // 2:1 aspect ratio
    );

    // Test position
    Vec3 pos = camera.position();
    assert(fequals(pos.x, 0.0f));
    assert(fequals(pos.y, 0.0f));
    assert(fequals(pos.z, 0.0f));

    // Center ray should point straight ahead
    Ray centerRay = camera.getRay(Vec2(0.5f, 0.5f));
    assert(centerRay.origin == Vec3(0, 0, 0));
    Vec3 centerDir = centerRay.direction.normalized();
    assert(fequals(centerDir.x, 0.0f));
    assert(fequals(centerDir.y, 0.0f));
    assert(centerDir.z < 0.0f);

    // Corner rays should diverge
    Ray cornerRay = camera.getRay(Vec2(0.0f, 0.0f));
    assert(cornerRay.origin == Vec3(0, 0, 0));

    // Coordinates are clamped to 0-1
    Ray clampedRay = camera.getRay(Vec2(-1.0f, 2.0f));
    Ray expectedRay = camera.getRay(Vec2(0.0f, 1.0f));
    assert(clampedRay.direction == expectedRay.direction);
}
