module lib.scene.world;

import lib.math.vec : Vec3;
import lib.math.ray : Ray;
import lib.scene.camera : Camera;
import lib.geom.hittable : Hittable;

class World : Hittable
{
    Camera camera;
    Hittable[] objects;

    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo)
    {
        HitInfo tmpHit;
        bool hitAnything = false;
        float closestHit = timeMax;
        foreach (obj; this.objects)
        {
            if (obj.hit(r, timeMin, closestHit, tmpHit))
            {
                hitAnything = true;
                closestHit = tmpHit.time;
                hitInfo = tmpHit;
            }
        }
        return hitAnything;
    }
}

// TODO: UNIT TESTS
