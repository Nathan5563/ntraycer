module lib.scene.camera.pinhole;

import lib.core.math : Vec2, Vec3, Ray, degToRad, tan, clamp;
import lib.scene.camera.camera : Camera;

class PinholeCamera : Camera
{
    private Vec3 origin;
    private Vec3 lowerLeft;
    private Vec3 horizontal;
    private Vec3 vertical;

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

    Vec3 position() const
    {
        return origin;
    }
    Ray getRay(Vec2 coord) const
    {
        Vec3 direction = lowerLeft +
                         clamp(coord.u, 0.0f, 1.0f) * horizontal +
                         clamp(coord.v, 0.0f, 1.0f) * vertical -
                         origin;
        return Ray(origin, direction);
    }
}

// TODO: UNIT TESTS
