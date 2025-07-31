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

// TODO: UNIT TESTS
