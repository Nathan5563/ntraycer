module lib.math.utils;

import lib.base.utils : isFloatingPoint, isIntegral;

const float EPSILON = 1e-4f;
const float PI = 3.14159265f;

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
bool fequals(const float num1, const float num2, float maxRelDiff = EPSILON, float maxAbsDiff = EPSILON) 
@nogc @safe pure nothrow
{
    float diff = abs(num1 - num2);
    if (diff <= maxAbsDiff)
    {
        return true;
    }
    else
    {
        return diff <= max(abs(num1), abs(num2)) * maxRelDiff;        
    }
}

pragma(inline, true)
float pow(const float base, const int exp) @nogc @safe pure nothrow
{
    assert(!((exp <= 0) && fequals(base, 0.0f)));

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
    assert(num > 0);

    const float x2 = num * 0.5f;
    float y = num;

    int i = *cast(int*)&y;
    i = 0x5f3759df - (i >> 1);
    y = *cast(float*)&i;

    y = y * (1.5f - (x2 * y * y));
    y = y * (1.5f - (x2 * y * y));
    y = y * (1.5f - (x2 * y * y));

    return y;
}

pragma(inline, true)
float sqrt(const float num) @nogc pure nothrow
{
    if (abs(num) < EPSILON)
    {
        return 0.0f;
    }
    else
    {
        return 1.0f / inverseSqrt(num);
    }
}

pragma(inline, true)
float acos(const float num) @nogc pure nothrow
{
    float n = clamp(num, -1.0f, 1.0f);

    const bool negate = n < 0.0f;
    n = abs(n);

    float ret = -0.0187293f;
    ret = ret * n + 0.0742610f;
    ret = ret * n - 0.2121144f;
    ret = ret * n + 1.5707288f;
    ret *= sqrt(1.0f - n);

    return negate ? (PI - ret) : ret;
}

unittest
{
    // abs
    static assert(abs(5) == 5);
    static assert(abs(-5) == 5);
    static assert(abs(0) == 0);
    static assert(abs(5.5f) == 5.5f);
    static assert(abs(-5.5f) == 5.5f);
    static assert(abs(0.0f) == 0.0f);
    static assert(abs(int.min) == int.min);
    static assert(abs(123) == 123);
    static assert(abs(-123) == 123);
    static assert(abs(0) == 0);
    static assert(abs(1.23f) == 1.23f);
    static assert(abs(-1.23f) == 1.23f);
    static assert(abs(0.0f) == 0.0f);

    // max
    static assert(max(5, 10) == 10);
    static assert(max(10, 5) == 10);
    static assert(max(-5, -10) == -5);
    static assert(max(5.5f, 10.5f) == 10.5f);
    static assert(max(5, 5) == 5);
    static assert(max(int.max, int.min) == int.max);
    static assert(max(-1.0f, 1.0f) == 1.0f);

    // min
    static assert(min(-1.0f, 1.0f) == -1.0f);
    static assert(min(5, 5) == 5);
    static assert(min(int.max, int.min) == int.min);
    static assert(min(5, 10) == 5);
    static assert(min(10, 5) == 5);
    static assert(min(-5, -10) == -10);
    static assert(min(5.5f, 10.5f) == 5.5f);

    // clamp
    static assert(clamp(5, 0, 10) == 5);
    static assert(clamp(-5, 0, 10) == 0);
    static assert(clamp(15, 0, 10) == 10);
    static assert(clamp(5.5f, 0.0f, 10.0f) == 5.5f);
    static assert(clamp(-5.5f, 0.0f, 10.0f) == 0.0f);
    static assert(clamp(15.5f, 0.0f, 10.0f) == 10.0f);

    // fequals
    static assert(fequals(1.0f, 1.0f));
    static assert(fequals(1.0f, 1.0f + EPSILON / 2.0f));
    static assert(!fequals(1.0f, 1.0f + EPSILON * 2.0f));
    static assert(fequals(0.0f, 0.0f));
    static assert(fequals(-1.0f, -1.0f));
    static assert(fequals(0.0f, 0.0f));
    static assert(!fequals(0.0f, EPSILON * 2));
    static assert(fequals(1e10f, 1e10f * (1 + EPSILON / 2)));
    static assert(!fequals(1e10f, 1e10f * (1 + EPSILON * 2)));
    static assert(fequals(-EPSILON / 2, 0.0f));
    static assert(!fequals(-EPSILON * 2, 0.0f));

    // pow, fequals
    static assert(fequals(pow(2.0f, 3), 8.0f));
    static assert(fequals(pow(2.0f, -3), 0.125f));
    static assert(fequals(pow(5.0f, 0), 1.0f));
    static assert(fequals(pow(-2.0f, 2), 4.0f));
    static assert(fequals(pow(-2.0f, 3), -8.0f));
    static assert(fequals(pow(0.0f, 5), 0.0f));
    static assert(fequals(pow(2.0f, 20), 1_048_576.0f));
    static assert(fequals(pow(2.0f, -20), 9.53674316e-07f));
    static assert(fequals(pow(-2.0f, 4), 16.0f));
    static assert(fequals(pow(-2.0f, 5), -32.0f));

    // inverseSqrt, fequals, sqrt
    static assert(fequals(inverseSqrt(4.0f), 0.5f));
    static assert(fequals(inverseSqrt(16.0f), 0.25f));
    static assert(fequals(inverseSqrt(2.0f), 0.70710678f));
    static assert(fequals(inverseSqrt(1e-3f), 1.0f / sqrt(1e-3f)));
    static assert(fequals(inverseSqrt(1e6f), 1.0f / sqrt(1e6f)));
    static assert(fequals(inverseSqrt(EPSILON), 1.0f / sqrt(EPSILON)));

    // sqrt, fequals
    static assert(fequals(sqrt(4.0f), 2.0f));
    static assert(fequals(sqrt(16.0f), 4.0f));
    static assert(fequals(sqrt(2.0f), 1.41421356f));
    static assert(fequals(sqrt(0.0f), 0.0f));
    static assert(fequals(sqrt(EPSILON / 2), sqrt(EPSILON / 2)));
    static assert(fequals(sqrt(1e6f), 1000.0f));

    // acos, fequals
    static assert(fequals(acos(1.0f), 0.0f));
    static assert(fequals(acos(0.0f), PI / 2.0f));
    static assert(fequals(acos(-1.0f), PI));
    static assert(fequals(acos(0.5f), PI / 3.0f));
    static assert(fequals(acos(-0.5f), 2.0f * PI / 3.0f));
    static assert(fequals(acos(1.1f), 0.0f));
    static assert(fequals(acos(-1.1f), PI));
    static assert(fequals(acos(1.0f - EPSILON / 10), 0.0f));
    static assert(fequals(acos(-1.0f + EPSILON / 10), PI));
    static assert(fequals(acos(0.76f) + acos(-0.76f), PI));
}
