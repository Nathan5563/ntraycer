module lib.renderer.renderer;

import lib.core.math : Vec2, Vec3, Ray, clamp, abs, max;
import lib.scene.scene : Scene;
import lib.scene.hittable.hittable : HitInfo;
import lib.renderer.film : Film, Pixel;

class Renderer
{
    Film film;

    this(int width, int height)
    {
        this.film = new Film(width, height);
    }

    void render(ref const Scene scene)
    {
        foreach (int y; 0 .. film.height)
        {
            foreach (int x; 0 .. film.width)
            {
                float u = cast(float)(x) / (film.width - 1);
                float v = cast(float)(y) / (film.height - 1);

                Ray ray = scene.camera.getRay(Vec2(u, v));
                HitInfo hitInfo;
                if (scene.hit(ray, 0.001f, float.infinity, hitInfo))
                {
                    Vec3 N = hitInfo.normal.normalized();
                    Vec3 L = Vec3(1, 1, 1).normalized();
                    float intensity = max(N.dot(L), 0.0f);
                    ubyte gray = cast(ubyte)(255.99f * intensity);
                    film.setPixel(x, y, Pixel(gray, gray, gray));
                }
                else
                {
                    Vec3 unit = ray.direction.normalized();
                    float t = 0.5f * (unit.y + 1.0f);
                    Vec3 backgroundColor = (1.0f - t)* Vec3(1.0f, 1.0f, 1.0f) + 
                                            t * Vec3(0.5f, 0.7f, 1.0f);
                    ubyte r = cast(ubyte)(
                        255.99f * clamp(backgroundColor.x, 0.0f, 1.0f)
                    );
                    ubyte g = cast(ubyte)(
                        255.99f * clamp(backgroundColor.y, 0.0f, 1.0f)
                    );
                    ubyte b = cast(ubyte)(
                        255.99f * clamp(backgroundColor.z, 0.0f, 1.0f)
                    );
                    film.setPixel(x, y, Pixel(r, g, b));
                }
            }
        }
    }
}

// TODO: UNIT TESTS
