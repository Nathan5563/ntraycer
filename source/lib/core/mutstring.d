// COMPLETE, ADD DOCS
/**
 * This module provides functionality for mutable strings. It is used to
 * convert the rendered image into a text-based file format.
 */
module lib.core.mutstring;

/// @struct Mutable string
struct MutString
{
    private char[] buf;
    private size_t length;

    this(string...)(const string args)
    {
        this.append(args);
    }

    char opIndex(size_t idx) const
    {
        return this.buf[idx];
    }
    bool opEquals(const MutString s) const
    {
        if (this.length != s.size())
        {
            return false;
        }
        foreach (i; 0 .. this.length)
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

    size_t size() const
    {
        return this.length;
    }
    const(char*) ptr() const
    {
        return this.buf.ptr;
    }
    void append(string...)(const string args)
    {
        foreach (s; args)
        {
            size_t newSize = this.length + s.length;
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
                this.buf[this.length + idx] = ch;
            }
            this.length += s.length;
        }
    }
    string toString() const
    {
        return (this.buf[0 .. this.length]).idup; 
    }

    alias toString this;
}

unittest
{
    // MutString
    auto s1 = MutString("hello");
    assert(s1.toString() == "hello");
    auto s_empty = MutString();
    assert(s_empty.toString() == "");
    auto s_multi = MutString("one", "two", "three");
    assert(s_multi.toString() == "onetwothree");

    // opIndex
    assert(s1[0] == 'h');
    assert(s1[4] == 'o');

    // opEquals
    const auto s_eq1 = MutString("test");
    const auto s_eq2 = MutString("test");
    const auto s_eq3 = MutString("different");
    const auto s_eq4 = MutString("tes");
    assert(s_eq1 == s_eq2);
    assert(s_eq2 == s_eq1);
    assert(s_eq1 != s_eq3);
    assert(s_eq1 != s_eq4);
    assert(s_eq3 != s_eq1);
    assert(s_eq4 != s_eq1);

    // ptr
    auto s_ptr = MutString("ptr test");
    const char* ptr = s_ptr.ptr();
    assert(ptr[0] == 'p');
    assert(ptr[1] == 't');
    assert(ptr[2] == 'r');
    assert(ptr[3] == ' ');
    assert(ptr[4] == 't');
    assert(ptr[5] == 'e');
    assert(ptr[6] == 's');
    assert(ptr[7] == 't');

    // toString
    const auto s_tostring = MutString("test");
    const string str_tostring = s_tostring;
    const string explicit_str_tostring = s_tostring.toString();
    assert(str_tostring == "test");
    assert((explicit_str_tostring == "test"));

    // append
    auto s_append = MutString("hello");
    s_append.append(" world");
    assert(s_append == "hello world");
    assert(s_append[6] == 'w');
    auto s_append_multi = MutString();
    s_append_multi.append("a", "b", "c");
    assert(s_append_multi == "abc");
    auto s_append_empty = MutString("test");
    s_append_empty.append("");
    assert(s_append_empty == "test");
    auto s_realloc = MutString();
    string longString;
    foreach(i; 0..200)
    {
        longString ~= "a";
    }
    s_realloc.append(longString);
    assert(s_realloc.size() == 200);
    assert(s_realloc == longString);
    assert(s_realloc[199] == 'a');
}
