module app;

import lib.core.file : sys_open, sys_write, sys_close, FileFlags, FilePermissions;
import lib.core.math : Vec3;
import lib.core.mutstring : MutString;
import lib.scene.camera.pinhole : PinholeCamera;
import lib.scene.hittable.hittable : Hittable;
import lib.scene.hittable.sphere : Sphere;
import lib.scene.hittable.mesh : Quad;
import lib.scene.scene : Scene;
import lib.scene.background : SolidBackground;
import lib.scene.material.lambertian : Lambertian;
import lib.scene.material.dielectric : Dielectric;
import lib.scene.material.metal : Metal;
import lib.scene.material.emissive : Emissive;
import lib.renderer.renderer : Renderer;
import lib.renderer.film : Film, ImageFormat;

void main()
{
	// Cornell Box dimensions
	const float boxSize = 8.0f;
	const float half = boxSize / 2.0f;

	// Materials
	auto white = new Lambertian(Vec3(0.73f, 0.73f, 0.73f));
	auto red = new Lambertian(Vec3(0.65f, 0.05f, 0.05f));
	auto blue = new Lambertian(Vec3(0.12f, 0.15f, 0.65f));
	auto light = new Emissive(Vec3(1.0f, 0.95f, 0.9f), 15.0f);
	auto mirror = new Metal(Vec3(0.95f, 0.95f, 0.95f), 0.0f);
	auto glass = new Dielectric(1.5f);

	// Camera looking into the box
	PinholeCamera camera = new PinholeCamera(
		Vec3(0, 0, -half * 2.5f),  // lookFrom - outside the box
		Vec3(0, 0, 0),             // lookAt - center of box
		Vec3(0, 1, 0),             // up vector
		50.0f,                     // FOV
		1.0f                       // aspect ratio (square)
	);

	Hittable[] objects = [
		// Floor (white)
		cast(Hittable) new Quad(
			Vec3(-half, -half, -half),
			Vec3(half, -half, -half),
			Vec3(half, -half, half),
			Vec3(-half, -half, half),
			white
		),

		// Ceiling (white)
		cast(Hittable) new Quad(
			Vec3(-half, half, half),
			Vec3(half, half, half),
			Vec3(half, half, -half),
			Vec3(-half, half, -half),
			white
		),

		// Back wall (white)
		cast(Hittable) new Quad(
			Vec3(-half, -half, half),
			Vec3(half, -half, half),
			Vec3(half, half, half),
			Vec3(-half, half, half),
			white
		),

		// Left wall (red)
		cast(Hittable) new Quad(
			Vec3(-half, -half, -half),
			Vec3(-half, -half, half),
			Vec3(-half, half, half),
			Vec3(-half, half, -half),
			red
		),

		// Right wall (blue)
		cast(Hittable) new Quad(
			Vec3(half, -half, half),
			Vec3(half, -half, -half),
			Vec3(half, half, -half),
			Vec3(half, half, half),
			blue
		),

		// Ceiling light (smaller quad in center of ceiling)
		cast(Hittable) new Quad(
			Vec3(-1.5f, half - 0.01f, -1.5f),
			Vec3(1.5f, half - 0.01f, -1.5f),
			Vec3(1.5f, half - 0.01f, 1.5f),
			Vec3(-1.5f, half - 0.01f, 1.5f),
			light
		),

		// Left sphere (mirror)
		cast(Hittable) new Sphere(Vec3(-1.8f, -half + 1.5f, 0.8f), 1.5f, mirror),

		// Right sphere (glass)
		cast(Hittable) new Sphere(Vec3(2.0f, -half + 1.8f, -0.5f), 1.8f, glass),
	];

	// Black background (closed box, no outside light)
	auto background = new SolidBackground(Vec3(0.0f, 0.0f, 0.0f));
	Scene world = new Scene(camera, objects, background);

	// Higher samples for better quality with area light
	Renderer renderer = new Renderer(600, 600, 400, 20);
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
