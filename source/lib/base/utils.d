/**
 * This module provides base functionality for common utilities.
 */
module lib.base.utils;

import lib.math.utils : abs;

template isIntegral(T)
{
    enum bool isIntegral = 
        is(T == byte) ||
        is(T == ubyte) ||
        is(T == short) ||
        is(T == ushort) ||
        is(T == int) ||
        is(T == uint) ||
        is(T == long) ||
        is(T == ulong) ||
        is(T == char) ||
        is(T == wchar) ||
        is(T == dchar);
}

template isFloatingPoint(T)
{
    enum bool isFloatingPoint = 
        is(T == float) ||
        is(T == double) ||
        is(T == real);
}

string intToString(const int value)
{
    long v = value;
    char[32] buf;
    size_t size = buf.length;

    const bool neg = v < 0;
    v = abs(v);
    do
    {
        buf[--size] = cast(char)('0' + (v % 10));
        v /= 10;
    }
    while (v > 0);

    if (neg)
    {
        buf[--size] = '-';
    }

    return buf[size .. $].idup;
}

unittest
{
    // isIntegral
    static assert(isIntegral!int);
    static assert(isIntegral!uint);
    static assert(isIntegral!short);
    static assert(isIntegral!ushort);
    static assert(isIntegral!long);
    static assert(isIntegral!ulong);
    static assert(isIntegral!byte);
    static assert(isIntegral!ubyte);
    static assert(isIntegral!char);
    static assert(isIntegral!wchar);
    static assert(isIntegral!dchar);
    static assert(!isIntegral!float);
    static assert(!isIntegral!double);
    static assert(!isIntegral!real);

    // isFloatingPoint
    static assert(isFloatingPoint!float);
    static assert(isFloatingPoint!double);
    static assert(isFloatingPoint!real);
    static assert(!isFloatingPoint!int);
    static assert(!isFloatingPoint!char);

    // intToString
    assert(intToString(0) == "0");
    assert(intToString(123) == "123");
    assert(intToString(-123) == "-123");
    assert(intToString(100) == "100");
    assert(intToString(-100) == "-100");
    assert(intToString(int.max) == "2147483647");
    assert(intToString(int.min) == "-2147483648");
    assert(intToString(9) == "9");
    assert(intToString(-9) == "-9");
}
