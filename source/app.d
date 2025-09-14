import lib.core.file : sys_open, sys_write, sys_close, FileFlags, FilePermissions;
import lib.core.math : Vec3;
import lib.core.mutstring : MutString;
import lib.scene.camera.pinhole : PinholeCamera;
import lib.scene.hittable.sphere : Sphere;
import lib.scene.material.lambertian : Lambertian;
import lib.scene.material.metal : Metal;
import lib.scene.material.dielectric : Dielectric;
import lib.scene.scene : Scene;
import lib.renderer.renderer : Renderer;
import lib.renderer.film : Film, ImageFormat;
import lib.core.random : srand;

void main()
{
        srand(1);

        PinholeCamera camera = new PinholeCamera(
                Vec3(0, 0, 0), Vec3(0, 0, -1), Vec3(0, 1, 0), 45.0f, 1.0f
        );

        Sphere ground = new Sphere(
                Vec3(0, -100.5f, -1), 100.0f,
                new Lambertian(Vec3(0.8f, 0.8f, 0.0f))
        );
        Sphere center = new Sphere(
                Vec3(0, 0, -1), 0.5f,
                new Lambertian(Vec3(0.7f, 0.3f, 0.3f))
        );
        Sphere left = new Sphere(
                Vec3(-1, 0, -1), 0.5f,
                new Dielectric(1.5f)
        );
        Sphere right = new Sphere(
                Vec3(1, 0, -1), 0.5f,
                new Metal(Vec3(0.8f, 0.6f, 0.2f), 0.0f)
        );
        Scene world = new Scene(camera, [ground, center, left, right]);

        Renderer renderer = new Renderer(400, 225, 100, 50);
        renderer.render(world);

        MutString image = renderer.film.save(ImageFormat.PPM);

	const int flags = FileFlags.WRONLY | FileFlags.CREAT | FileFlags.TRUNC;
	const int perm = FilePermissions.o644;
	const int fd = sys_open("image.ppm", flags, perm);
	assert(!(fd < 0));

	const ptrdiff_t nbytes = sys_write(fd, image.ptr(), image.size());
	assert(nbytes == image.size());
	
	const int ret = sys_close(fd);
	assert(!(ret < 0));
}
