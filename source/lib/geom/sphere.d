module lib.geom.sphere;

import lib.math.vec : Vec3;
import lib.math.ray : Ray;
import lib.geom.hittable : Hittable, HitInfo;

class Sphere : Hittable
{
    Vec3 center;
    float radius;

    // TODO: constructor?

    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo)
    {
        return false;
    }
}

// TODO: UNIT TESTS
