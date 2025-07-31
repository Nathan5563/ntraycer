import lib.base.file;
import lib.base.string;
import lib.render.scene;
import lib.render.renderer;

void main()
{
	Scene scene = Scene();
	Renderer renderer = Renderer(255, 255);
	renderer.render(scene);
	String image = renderer.film.save(ImageFormat.PPM);

	int flags = FileFlags.WRONLY | FileFlags.CREAT | FileFlags.TRUNC;
	int perm = FilePermissions.o644;
	int fd = sys_open("image.ppm", flags, perm);
	assert(!(fd < 0));

	ptrdiff_t nbytes = sys_write(fd, image.buf.ptr, image.size);
	assert(nbytes == image.size);
	
	int ret = sys_close(fd);
	assert(!(ret < 0));
}
