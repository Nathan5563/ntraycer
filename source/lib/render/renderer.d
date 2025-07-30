module lib.render.renderer;

import lib.base.string;
import lib.base.utils : intToString;
import lib.render.scene;

enum ImageFormat
{
    PPM
}

struct Pixel
{
    ubyte r;
    ubyte g;
    ubyte b;

    this(const ubyte r, const ubyte g, const ubyte b)
    {
        this.r = r;
        this.g = g;
        this.b = b;
    }
}

struct Film
{
    Pixel[] screen;
    int width;
    int height;

    this(const int width, const int height)
    {
        this.width = width;
        this.height = height;
        this.screen.length = width * height;
    }

    Pixel getPixel(const int x, const int y) const
    {
        return this.screen[y * this.width + x];
    }
    void setPixel(const int x, const int y, const Pixel color)
    {
        screen[y * this.width + x] = color;
    }
    void clear(const Pixel color = Pixel())
    {
        foreach (ref pixel; screen)
        {
            pixel = color;
        }
    }
    String save(ImageFormat format) const
    {
        assert(format == ImageFormat.PPM);
        String image = String(
            "P3\n",
            intToString(this.width), " ", intToString(this.height), "\n",
            "255\n"
        );
        foreach (y; 0 .. this.height)
        {
            foreach (x; 0 .. this.width)
            {
                Pixel p = this.screen[y * this.width + x];
                image.append(
                    intToString(p.r), " ", intToString(p.g), " ", intToString(p.b), " "
                );
            }
            image.append("\n");
        }
        return image;
    }
}

struct Renderer
{
    Film film;

    this(const int width, const int height)
    {
        this.film = Film(width, height);
    }

    void render(ref const Scene scene)
    {
        return;
    }
}

// TODO: UNIT TESTS
