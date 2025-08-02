// COMPLETE, ADD DOCS, ADD TESTS
module lib.renderer.film;

import lib.core.mutstring : MutString;
import lib.core.math : intToString;

enum ImageFormat
{
    PPM
}

struct Pixel
{
    ubyte r;
    ubyte g;
    ubyte b;

    this(ubyte r, ubyte g, ubyte b)
    {
        this.r = r;
        this.g = g;
        this.b = b;
    }
}

class Film
{
    private Pixel[] screen;
    int width;
    int height;

    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        this.screen.length = width * height;
    }

    Pixel getPixel(int x, int y) const
    {
        return this.screen[y * this.width + x];
    }
    void setPixel(int x, int y, Pixel color)
    {
        this.screen[y * this.width + x] = color;
    }
    void clear(Pixel color = Pixel())
    {
        foreach (ref pixel; this.screen)
        {
            pixel = color;
        }
    }
    MutString save(ImageFormat format) const
    {
        assert(format == ImageFormat.PPM);
        MutString image = MutString(
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

// TODO: UNIT TESTS
