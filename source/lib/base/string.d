/**
 * This module provides base functionality for mutable strings. It is used by
 * `source/lib/render/renderer.d` to convert the rendered image into a text
 * format.
 */
module lib.base.string;

/// @struct Mutable string
struct String
{
    char[] buf;
    size_t size;

    this(string...)(const string args)
    {
        this.append(args);
    }

    char opIndex(size_t idx) const
    {
        return this.buf[idx];
    }

    void append(string...)(const string args)
    {
        foreach (s; args)
        {
            size_t newSize = this.size + s.length;
            if (this.buf.length < newSize)
            {
                size_t newLength;
                if (this.buf.length == 0)
                {
                    newLength = 128;
                }
                else
                {
                    newLength = this.buf.length;    
                }

                while (newLength < newSize)
                {
                    newLength *= 2;
                }
                this.buf.length = newLength;
            }
            foreach (idx, ch; s)
            {
                this.buf[this.size + idx] = ch;
            }
            this.size += s.length;
        }
    }
    private string toString() const
    {
        return (this.buf[0 .. this.size]).idup; 
    }

    alias toString this;
}

// TODO: UNIT TESTS
