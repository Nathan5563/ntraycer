module lib.math.utils;

import lib.base.utils : isFloatingPoint, isIntegral;

enum float EPSILON = 1e-6f;

pragma(inline, true)
T abs(T)(const T num)
@nogc @safe pure nothrow if (isFloatingPoint!T || isIntegral!T)
{
    if (num >= 0)
    {
        return num;
    }
    else
    {
        return -num;
    }
}

pragma(inline, true)
T max(T)(const T num1, const T num2)
@nogc @safe pure nothrow if (isFloatingPoint!T || isIntegral!T)
{
    if (num1 > num2)
    {
        return num1;
    }
    else
    {
        return num2;
    }
}

pragma(inline, true)
T min(T)(const T num1, const T num2)
@nogc @safe pure nothrow if (isFloatingPoint!T || isIntegral!T)
{
    if (num1 > num2)
    {
        return num2;
    }
    else
    {
        return num1;
    }
}

pragma(inline, true)
T clamp(T)(const T value, const T minVal, const T maxVal)
@nogc @safe pure nothrow if (isFloatingPoint!T || isIntegral!T)
{
    return max(minVal, min(maxVal, value));
}

pragma(inline, true)
bool fequals(const float num1, const float num2) @nogc @safe pure nothrow
{
    return abs(num1 - num2) < EPSILON;
}

pragma(inline, true)
float pow(const float base, const int exp) @nogc @safe pure nothrow
{
    assert(!((exp <= 0) && (abs(base) < EPSILON)));

    if (exp == 0)
    {
        return 1.0f;
    }
    else
    {
        float b = base;
        int e = exp;

        if (e < 0)
        {
            b = 1.0f / b;
            e = -e;
        }

        float res = 1.0f;
        while (e != 0)
        {
            if ((e & 1) != 0)
            {
                res *= b;
            }
            b *= b;
            e >>= 1;
        }

        return res;
    }
}

pragma(inline, true)
float inverseSqrt(const float num) @nogc pure nothrow
{
    assert(!(num < 0));
    assert(!(abs(num) < EPSILON));

    float x2 = num * 0.5f;
    float y = num;

    int i = *cast(int*)&y;
    i = 0x5f3759df - (i >> 1);
    y = *cast(float*)&i;

    y = y * (1.5f - (x2 * y * y));
    y = y * (1.5f - (x2 * y * y));

    return y;
}

pragma(inline, true)
float sqrt(const float num) @nogc pure nothrow
{
    return 1.0f / inverseSqrt(num);
}

pragma(inline, true)
float acos(const float num) @nogc pure nothrow
{
    float n = clamp(num, -1.0f, 1.0f);

    bool negate = n < 0.0f;
    n = abs(n);

    float ret = -0.0187293f;
    ret = ret * n + 0.0742610f;
    ret = ret * n - 0.2121144f;
    ret = ret * n + 1.5707288f;
    ret *= sqrt(1.0f - n);

    return negate ? (3.14159265f - ret) : ret;
}

// TODO: UNIT TESTS
