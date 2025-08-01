/**
 * This module provides base functionality for mutable strings. It is used to
 * convert the rendered image into a text-based file format.
 */
module lib.base.string;

/// @struct Mutable string
struct String
{
    private char[] buf;
    /// @prop size - the length of the string
    size_t size;

    this(string...)(const string args)
    {
        this.append(args);
    }

    char opIndex(size_t idx) const
    {
        return this.buf[idx];
    }
    bool opEquals(const String s) const
    {
        if (this.size != s.size)
        {
            return false;
        }
        foreach (i; 0 .. this.size)
        {
            if (this.buf[i] != s.buf[i])
            {
                return false;
            }
        }
        return true;
    }
    bool opEquals(const string s) const
    {
        return this.toString() == s;
    }

    const(char*) getPtr() const
    {
        return this.buf.ptr;
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
    string toString() const
    {
        return (this.buf[0 .. this.size]).idup; 
    }

    alias toString this;
}

unittest
{
    // constructor
    auto s1 = String("hello");
    assert(s1.toString() == "hello");
    auto s_empty = String();
    assert(s_empty.toString() == "");
    auto s_multi = String("one", "two", "three");
    assert(s_multi.toString() == "onetwothree");

    // opIndex
    assert(s1[0] == 'h');
    assert(s1[4] == 'o');

    // opEquals
    const auto s_eq1 = String("test");
    const auto s_eq2 = String("test");
    const auto s_eq3 = String("different");
    const auto s_eq4 = String("tes");
    assert(s_eq1 == s_eq2);
    assert(s_eq2 == s_eq1);
    assert(s_eq1 != s_eq3);
    assert(s_eq1 != s_eq4);
    assert(s_eq3 != s_eq1);
    assert(s_eq4 != s_eq1);

    // getPtr, opIndex
    auto s_ptr = String("ptr test");
    const char* ptr = s_ptr.getPtr();
    assert(ptr[0] == 'p');
    assert(ptr[1] == 't');
    assert(ptr[2] == 'r');
    assert(ptr[3] == ' ');
    assert(ptr[4] == 't');
    assert(ptr[5] == 'e');
    assert(ptr[6] == 's');
    assert(ptr[7] == 't');

    // toString
    const auto s_tostring = String("test");
    const string str_tostring = s_tostring;
    const string explicit_str_tostring = s_tostring.toString();
    assert(str_tostring == "test");
    assert((explicit_str_tostring == "test"));

    // append, toString
    auto s_append = String("hello");
    s_append.append(" world");
    assert(s_append == "hello world");
    assert(s_append[6] == 'w');
    auto s_append_multi = String();
    s_append_multi.append("a", "b", "c");
    assert(s_append_multi == "abc");
    auto s_append_empty = String("test");
    s_append_empty.append("");
    assert(s_append_empty == "test");
    auto s_realloc = String();
    string longString;
    foreach(i; 0..200)
    {
        longString ~= "a";
    }
    s_realloc.append(longString);
    assert(s_realloc.size == 200);
    assert(s_realloc == longString);
    assert(s_realloc[199] == 'a');
}
