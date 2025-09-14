module lib.renderer.renderer;

import lib.core.math : Vec2, Vec3, Ray, clamp, sqrt;
import lib.scene.scene : Scene;
import lib.scene.hittable.hittable : HitInfo;
import lib.renderer.film : Film, Pixel;
import lib.core.random : randf;

class Renderer
{
    Film film;
    int samplesPerPixel;
    int maxDepth;

    this(int width, int height, int samplesPerPixel = 100, int maxDepth = 50)
    {
        this.film = new Film(width, height);
        this.samplesPerPixel = samplesPerPixel;
        this.maxDepth = maxDepth;
    }

    Vec3 rayColor(Ray ray, ref const Scene scene, int depth)
    {
        if (depth <= 0)
        {
            return Vec3(0.0f, 0.0f, 0.0f);
        }

        HitInfo hitInfo;
        if (scene.hit(ray, 0.001f, float.infinity, hitInfo))
        {
            Ray scattered;
            Vec3 attenuation;
            if (hitInfo.material.scatter(ray, hitInfo, attenuation, scattered))
            {
                return attenuation * rayColor(scattered, scene, depth - 1);
            }
            return Vec3(0.0f, 0.0f, 0.0f);
        }

        Vec3 unit = ray.direction.normalized();
        float t = 0.5f * (unit.y + 1.0f);
        return (1.0f - t) * Vec3(1.0f, 1.0f, 1.0f) +
               t * Vec3(0.5f, 0.7f, 1.0f);
    }

    void render(ref const Scene scene)
    {
        foreach (int y; 0 .. film.height)
        {
            foreach (int x; 0 .. film.width)
            {
                Vec3 color = Vec3(0.0f, 0.0f, 0.0f);
                foreach (int s; 0 .. samplesPerPixel)
                {
                    float u = (cast(float)(x) + randf()) / (film.width - 1);
                    float v = (cast(float)(y) + randf()) / (film.height - 1);
                    Ray ray = scene.camera.getRay(Vec2(u, v));
                    color = color + rayColor(ray, scene, maxDepth);
                }

                color = color / cast(float)samplesPerPixel;
                color = Vec3(
                    sqrt(clamp(color.x, 0.0f, 1.0f)),
                    sqrt(clamp(color.y, 0.0f, 1.0f)),
                    sqrt(clamp(color.z, 0.0f, 1.0f))
                );
                ubyte r = cast(ubyte)(255.99f * clamp(color.x, 0.0f, 1.0f));
                ubyte g = cast(ubyte)(255.99f * clamp(color.y, 0.0f, 1.0f));
                ubyte b = cast(ubyte)(255.99f * clamp(color.z, 0.0f, 1.0f));
                film.setPixel(x, y, Pixel(r, g, b));
            }
        }
    }
}

// TODO: UNIT TESTS
