import lib.base.file;
import lib.base.string;
import lib.scene.world;
import lib.render.renderer;
import lib.render.film;

void main()
{
	World world = new World;
	Renderer renderer = new Renderer(255, 255);
	renderer.render(world);
	String image = renderer.film.save(ImageFormat.PPM);

	const int flags = FileFlags.WRONLY | FileFlags.CREAT | FileFlags.TRUNC;
	const int perm = FilePermissions.o644;
	const int fd = sys_open("image.ppm", flags, perm);
	assert(!(fd < 0));

	const ptrdiff_t nbytes = sys_write(fd, image.getPtr(), image.size);
	assert(nbytes == image.size);
	
	const int ret = sys_close(fd);
	assert(!(ret < 0));
}
