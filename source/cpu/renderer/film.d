// COMPLETE
/**
 * This module provides the Film class which represents the image buffer
 * where rendered pixels are stored, and can be saved to various formats.
 */
module cpu.renderer.film;

import cpu.core.mutstring : MutString;
import cpu.core.math : intToString;

/// @enum ImageFormat - Supported output image formats
enum ImageFormat
{
    PPM
}

/// @struct Pixel - An RGB pixel with 8-bit color channels
struct Pixel
{
    /// @prop r - red channel (0-255)
    ubyte r;
    /// @prop g - green channel (0-255)
    ubyte g;
    /// @prop b - blue channel (0-255)
    ubyte b;

    /// @func this - Creates a pixel with specified RGB values
    this(ubyte r, ubyte g, ubyte b)
    {
        this.r = r;
        this.g = g;
        this.b = b;
    }
}

/// @class Film - Image buffer for storing rendered pixels
class Film
{
    private Pixel[] screen;
    /// @prop width - image width in pixels
    int width;
    /// @prop height - image height in pixels
    int height;

    /// @func this - Creates a new film buffer
    ///
    /// @param width - image width in pixels
    /// @param height - image height in pixels
    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        this.screen.length = width * height;
    }

    /// @func getPixel - Retrieves the pixel at the given coordinates
    ///
    /// @param x - x coordinate (0 to width-1)
    /// @param y - y coordinate (0 to height-1)
    ///
    /// @returns - the pixel at (x, y)
    Pixel getPixel(int x, int y) const
    {
        return this.screen[y * this.width + x];
    }

    /// @func setPixel - Sets the pixel at the given coordinates
    ///
    /// @param x - x coordinate (0 to width-1)
    /// @param y - y coordinate (0 to height-1)
    /// @param color - the pixel color to set
    void setPixel(int x, int y, Pixel color)
    {
        this.screen[y * this.width + x] = color;
    }

    /// @func clear - Fills the entire film with a single color
    ///
    /// @param color - the color to fill with (default black)
    void clear(Pixel color = Pixel())
    {
        foreach (ref pixel; this.screen)
        {
            pixel = color;
        }
    }

    /// @func save - Saves the film to an image format
    ///
    /// @param format - the output format (currently only PPM)
    ///
    /// @returns - the image data as a string
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

unittest
{
    // Test Film creation
    auto film = new Film(10, 5);
    assert(film.width == 10);
    assert(film.height == 5);

    // Test setPixel and getPixel
    film.setPixel(3, 2, Pixel(255, 128, 64));
    Pixel p = film.getPixel(3, 2);
    assert(p.r == 255);
    assert(p.g == 128);
    assert(p.b == 64);

    // Test clear
    film.clear(Pixel(100, 100, 100));
    foreach (y; 0 .. film.height)
    {
        foreach (x; 0 .. film.width)
        {
            Pixel px = film.getPixel(x, y);
            assert(px.r == 100);
            assert(px.g == 100);
            assert(px.b == 100);
        }
    }

    // Test default clear (black)
    film.clear();
    Pixel black = film.getPixel(0, 0);
    assert(black.r == 0);
    assert(black.g == 0);
    assert(black.b == 0);

    // Test Pixel creation
    Pixel white = Pixel(255, 255, 255);
    assert(white.r == 255);
    assert(white.g == 255);
    assert(white.b == 255);

    // Test PPM save format
    auto smallFilm = new Film(2, 2);
    smallFilm.setPixel(0, 0, Pixel(255, 0, 0));
    smallFilm.setPixel(1, 0, Pixel(0, 255, 0));
    smallFilm.setPixel(0, 1, Pixel(0, 0, 255));
    smallFilm.setPixel(1, 1, Pixel(255, 255, 255));
    MutString ppm = smallFilm.save(ImageFormat.PPM);
    assert(ppm.size() > 0);
}
