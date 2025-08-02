module lib.scene.scene;

import lib.core.math : Vec3, Ray;
import lib.scene.camera.camera : Camera;
import lib.scene.hittable.hittable : Hittable, HitInfo;

class Scene : Hittable
{
    Camera camera;
    private Hittable[] objects;

    this()
    {
        this.camera = null;
        this.objects = [];
    }
    this(Camera camera, Hittable[] objects)
    {
        this.camera = camera;
        this.objects = objects;
    }

    bool hit(Ray r, float timeMin, float timeMax, out HitInfo hitInfo) const
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
