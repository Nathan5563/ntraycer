module app;

import lib.core.file : sys_open, sys_write, sys_close, FileFlags, FilePermissions;
import lib.core.math : Vec3;
import lib.core.mutstring : MutString;
import lib.scene.camera.pinhole : PinholeCamera;
import lib.scene.hittable.hittable : Hittable;
import lib.scene.hittable.sphere : Sphere;
import lib.scene.hittable.mesh : Mesh;
import lib.scene.scene : Scene;
import lib.scene.material.lambertian : Lambertian;
import lib.scene.material.dielectric : Dielectric;
import lib.scene.material.metal : Metal;
import lib.renderer.renderer : Renderer;
import lib.renderer.film : Film, ImageFormat;

void main()
{
	PinholeCamera camera = new PinholeCamera(
		Vec3(0, 0.25, -6),    // lookFrom
		Vec3(0, -0.1, -1),    // lookAt
		Vec3(0, 1, 0),        // up vector
		60.0f,                // FOV
		16.0f / 9.0f          // aspect ratio
	);

	Hittable[] objects = [];
	Scene world = new Scene(camera, objects);

	Renderer renderer = new Renderer(800, 450, 100, 50);
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
