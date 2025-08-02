import lib.core.file : sys_open, sys_write, sys_close, FileFlags, FilePermissions;
import lib.core.math : Vec3;
import lib.core.mutstring : MutString;
import lib.scene.camera.pinhole : PinholeCamera;
import lib.scene.hittable.sphere : Sphere;
import lib.scene.material.lambertian : Lambertian;
import lib.scene.scene : Scene;
import lib.renderer.renderer : Renderer;
import lib.renderer.film : Film, ImageFormat;

void main()
{
	PinholeCamera camera = new PinholeCamera(
		Vec3(0, 0, 0), Vec3(0, 0, -1), Vec3(0, 1, 0), 45.0f, 1.0f
	);
	Sphere sphere = new Sphere(
		Vec3(0, 0, -1), 0.25f
	);
	Scene world = new Scene(camera, [sphere]);

	Renderer renderer = new Renderer(800, 800);
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
