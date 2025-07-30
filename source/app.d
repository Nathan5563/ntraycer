import core.file;
import core.string;

import core.utils : intToString;

void main()
{
	int width = 255;
	int height = 255;

	int fd = sys_open("image.ppm", O_WRONLY | O_CREAT | O_TRUNC, 420);
	assert(!(fd < 0));
	
	String image = String("P3\n", intToString(height), " ", intToString(width), "\n255\n");
	foreach (row; 0 .. width)
	{
		foreach (col; 0 .. height)
		{
			image.append(intToString(row), " ", intToString(col), " 0  ");
			if ((col + 1) % 3 == 0)
			{
				image.append("\n");
			}
		}
	}

	ptrdiff_t nbytes = sys_write(fd, image.buf.ptr, image.size);
	assert(nbytes == image.size);

	int ret = sys_close(fd);
	assert(!(ret < 0));
}
