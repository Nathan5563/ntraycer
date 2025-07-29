module math.utils;

import std.math : isNaN, isInfinity;

enum float EPSILON = 1e-6f;

float abs(float num)
{
    if (num >= 0.0f)
    {
        return num;
    }
    else
    {
        return -num;
    }
}

float pow(float base, int exp)
{
    if (isnan(base) || isInfinity(base))
    {
        throw new Exception("Invalid float");
    }
    if ((exp <= 0) && (abs(base) < EPSILON))
    {
        throw new Exception("Float is too close to 0 for stable computation");
    }

    if (exp == 0)
    {
        return 1.0f;
    }
    else
    {
        if (exp < 0)
        {
            base = 1.0f / base;
            exp = -exp;
        }

        float res = 1.0f;
        while (exp != 0)
        {
            if ((exp & 1) != 0)
            {
                res *= base;
            }
            base *= base;
            exp >>= 1;
        }

        return res;
    }
}

float inverseSqrt(float num)
{
    if (isnan(num) || isInfinity(num))
    {
        throw new Exception("Invalid float");
    }
    if (num < 0)
    {
        throw new Exception("Cannot compute square root of a negative number");
    }
    if (abs(num) < EPSILON)
    {
        throw new Exception("Float is too close to 0 for stable computation");
    }

    float x2 = num * 0.5f;
    float y = num;

    int i = *cast(int*)&y;
    i = 0x5f3759df - (i >> 1);
    y = *cast(float*)&i;

    y = y * (1.5f - (x2 * y * y));
    y = y * (1.5f - (x2 * y * y));

    return y;
}

float sqrt(float num)
{
    return 1.0f / inverseSqrt(num);
}

// TODO: UNIT TESTS
