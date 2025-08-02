// COMPLETE, ADD DOCS, ADD TESTS
/** 
 * This module provides all of the mathematical types necessary for the
 * project, and it includes helpful utility functions.
 */
module lib.core.math;

const float EPSILON = 1e-4f;
const float PI = 3.14159265f;

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

pragma(inline, true)
string intToString(int value)
@safe pure nothrow
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

pragma(inline, true)
T abs(T)(T num)
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
T max(T)(T num1, T num2)
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
T min(T)(T num1, T num2)
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
T clamp(T)(T value, T minVal, T maxVal)
@nogc @safe pure nothrow if (isFloatingPoint!T || isIntegral!T)
{
    return max(minVal, min(maxVal, value));
}

pragma(inline, true) 
bool fequals(
    float num1, 
    float num2, 
    float maxRelDiff = EPSILON, 
    float maxAbsDiff = EPSILON
) @nogc @safe pure nothrow
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
float degToRad(float deg)
@nogc @safe pure nothrow
{
    return deg * (PI / 180.0f);
}

pragma(inline, true)
float pow(float base, int exp)
@nogc @safe pure nothrow
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
float inverseSqrt(float num)
@nogc pure nothrow
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
float sqrt(float num)
@nogc pure nothrow
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
float tan(float x)
@nogc @safe pure nothrow
{
    int k = cast(int)(x / PI + (x >= 0 ? 0.5f : -0.5f));
    float y = x - k * PI;

    if (abs(y) > PI / 2.0f - EPSILON)
    {
        return y > 0 ? 1e10f : -1e10f;
    }

    const float y2 = y * y;
    float cf = 9.0f;
    cf = 7.0f - y2 / cf;
    cf = 5.0f - y2 / cf;
    cf = 3.0f - y2 / cf;
    cf = 1.0f - y2 / cf;

    return y / cf;
}

pragma(inline, true)
float acos(float num)
@nogc pure nothrow
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

struct Vec2
{
    float u;
    float v;

    this(float u, float v)
    {
        this.u = u;
        this.v = v;
    }

    bool opEquals(Vec2 rhs) const
	{
		return fequals(this.u, rhs.u) 
            && fequals(this.v, rhs.v) ;
	}
	Vec2 opUnary(string s)() const if (s == "-")
    {
        return Vec2(-this.u, -this.v);
    }
	Vec2 opBinary(string op : "+")(Vec2 rhs) const
    {
        return Vec2(this.u + rhs.u, this.v + rhs.v);
    }
	Vec2 opBinary(string op : "-")(Vec2 rhs) const
    {
        return Vec2(this.u - rhs.u, this.v - rhs.v);
    }
	Vec2 opBinary(string op : "*")(float rhs) const
	{
		return Vec2(this.u * rhs, this.v  * rhs);
	}
	Vec2 opBinary(string op : "/")(float rhs) const
	{
		return Vec2(this.u / rhs, this.v  / rhs);
	}
	Vec2 opBinaryRight(string op : "*")(float lhs) const
	{
		return Vec2(lhs * this.u, lhs * this.v);
	}
	
	float norm() const
	{
		return sqrt(
			this.u * this.u + this.v * this.v
		);
	}
	Vec2 normalized() const
	{
		return this * inverseSqrt(
			this.u * this.u + this.v * this.v
		);
	}
	float dot(Vec2 v) const
	{
		return this.u * v.u + this.v * v.v;
	}
	float distance(Vec2 v) const
	{
		return sqrt(
			(this.u - v.u) * (this.u - v.u) +
            (this.v - v.v) * (this.v - v.v)
		);
	}
}

struct Vec3
{
	float x;
    float y;
    float z;

	this(float x, float y, float z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

    bool opEquals(Vec3 rhs) const
	{
		return fequals(this.x, rhs.x) 
            && fequals(this.y, rhs.y) 
            && fequals(this.z, rhs.z);
	}
	Vec3 opUnary(string s)() const if (s == "-")
    {
        return Vec3(-this.x, -this.y, -this.z);
    }
	Vec3 opBinary(string op : "+")(Vec3 rhs) const
    {
        return Vec3(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);
    }
	Vec3 opBinary(string op : "-")(Vec3 rhs) const
    {
        return Vec3(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z);
    }
	Vec3 opBinary(string op : "*")(float rhs) const
	{
		return Vec3(this.x * rhs, this.y  * rhs, this.z * rhs);
	}
	Vec3 opBinary(string op : "/")(float rhs) const
	{
		return Vec3(this.x / rhs, this.y  / rhs, this.z / rhs);
	}
	Vec3 opBinaryRight(string op : "*")(float lhs) const
	{
		return Vec3(lhs * this.x, lhs * this.y, lhs * this.z);
	}
	
	float norm() const
	{
		return sqrt(
			this.x * this.x + this.y * this.y + this.z * this.z
		);
	}
	Vec3 normalized() const
	{
		return this * inverseSqrt(
			this.x * this.x + this.y * this.y + this.z * this.z
		);
	}
	float dot(const Vec3 v) const
	{
		return this.x * v.x + this.y * v.y + this.z * v.z;
	}
	Vec3 cross(Vec3 v) const
	{
		return Vec3(
			this.y * v.z - this.z * v.y,
			this.z * v.x - this.x * v.z,
			this.x * v.y - this.y * v.x
		);
	}
	float distance(Vec3 v) const
	{
		return sqrt(
			(this.x - v.x) * (this.x - v.x) +
            (this.y - v.y) * (this.y - v.y) +
            (this.z - v.z) * (this.z - v.z)
		);
	}
}

// TODO: UNIT TESTS (for Vec2)

struct Ray
{
	Vec3 origin;
	Vec3 direction;

	this(Vec3 origin, Vec3 direction)
	{
		this.origin = origin;
		this.direction = direction.normalized();
	}

	Vec3 at(float time) const
	{
		return origin + direction * time;
	}
	float distanceToPoint(Vec3 point) const
	{
		float time = direction.dot(point - origin);
		if (time < 0)
		{
			time = 0;
		}
		Vec3 closestPoint = origin + direction * time;
		return (closestPoint - point).norm();
	}
	float angleToRay(Ray r) const
	{
		float cosTheta = direction.dot(r.direction);
		if (cosTheta > 1.0f)
		{
			cosTheta = 1.0f;
		}
		else if (cosTheta < -1.0f)
		{
			cosTheta = -1.0f;
		}
		return acos(cosTheta);
	}
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

    // degToRad
    static assert(fequals(degToRad(0.0f), 0.0f));
    static assert(fequals(degToRad(180.0f), PI));
    static assert(fequals(degToRad(360.0f), 2.0f * PI));
    static assert(fequals(degToRad(90.0f), PI / 2.0f));
    static assert(fequals(degToRad(-90.0f), -PI / 2.0f));
    static assert(fequals(degToRad(45.0f), PI / 4.0f));
    static assert(fequals(degToRad(-45.0f), -PI / 4.0f));
    static assert(fequals(degToRad(30.0f), PI / 6.0f));
    static assert(fequals(degToRad(-30.0f), -PI / 6.0f));
    static assert(fequals(degToRad(60.0f), PI / 3.0f));
    static assert(fequals(degToRad(-60.0f), -PI / 3.0f));

    // pow
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
    static assert(fequals(pow(1.0f, 100), 1.0f));
    static assert(fequals(pow(1.0f, -100), 1.0f));
    static assert(fequals(pow(-1.0f, 100), 1.0f));
    static assert(fequals(pow(-1.0f, 101), -1.0f));
    static assert(fequals(pow(0.5f, 2), 0.25f));
    static assert(fequals(pow(0.5f, -2), 4.0f));

    // sqrt, inverseSqrt
    static assert(fequals(inverseSqrt(4.0f), 0.5f));
    static assert(fequals(inverseSqrt(16.0f), 0.25f));
    static assert(fequals(inverseSqrt(2.0f), 0.70710678f));
    static assert(fequals(inverseSqrt(1e-3f), 1.0f / sqrt(1e-3f)));
    static assert(fequals(inverseSqrt(1e6f), 1.0f / sqrt(1e6f)));
    static assert(fequals(inverseSqrt(EPSILON), 1.0f / sqrt(EPSILON)));
    static assert(fequals(inverseSqrt(1.0f), 1.0f));
    static assert(fequals(inverseSqrt(0.25f), 2.0f));
    static assert(fequals(inverseSqrt(0.01f), 10.0f));
    static assert(fequals(sqrt(4.0f), 2.0f));
    static assert(fequals(sqrt(16.0f), 4.0f));
    static assert(fequals(sqrt(2.0f), 1.41421356f));
    static assert(fequals(sqrt(0.0f), 0.0f));
    static assert(fequals(sqrt(EPSILON / 2), sqrt(EPSILON / 2)));
    static assert(fequals(sqrt(1e6f), 1000.0f));
    static assert(fequals(sqrt(0.25f), 0.5f));
    static assert(fequals(sqrt(0.01f), 0.1f));
    static assert(fequals(sqrt(1.0f), 1.0f));

    // tan
    static assert(fequals(tan(0.0f), 0.0f));
    static assert(fequals(tan(PI / 4.0f), 1.0f), tan(PI / 4.0f));
    static assert(fequals(tan(-PI / 4.0f), -1.0f));
    static assert(fequals(tan(PI / 6.0f), 0.57735027f));
    static assert(fequals(tan(-PI / 6.0f), -0.57735027f));
    static assert(fequals(tan(PI / 3.0f), 1.73205081f));
    static assert(fequals(tan(-PI / 3.0f), -1.73205081f));

    // acos
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
    static assert(fequals(acos(0.70710678f), PI / 4.0f));
    static assert(fequals(acos(-0.70710678f), 3.0f * PI / 4.0f));
    static assert(fequals(acos(0.8660254f), PI / 6.0f));
    static assert(fequals(acos(-0.8660254f), 5.0f * PI / 6.0f));

    // TODO: UNIT TESTS FOR Vec2

    // Vec3
    auto v1 = Vec3(1.0f, 2.0f, 3.0f);
    assert(v1.x == 1.0f && v1.y == 2.0f && v1.z == 3.0f);

    // opBinary "=="
    assert(Vec3(1.0f, 2.0f, 3.0f) == Vec3(1.0f, 2.0f, 3.0f));
    assert(Vec3(1.0f, 2.0f, 3.0f) != Vec3(3.0f, 2.0f, 1.0f));
    assert(Vec3(1.0f, 1.0f, 1.0f) == Vec3(1.0f + EPSILON/2, 1.0f + EPSILON/2, 1.0f + EPSILON/2));
    assert(Vec3(1.0f, 1.0f, 1.0f) != Vec3(1.0f + EPSILON*2, 1.0f + EPSILON*2, 1.0f + EPSILON*2));

    // opUnary "-"
    const auto v_neg = -v1;
    assert(v_neg == Vec3(-1.0f, -2.0f, -3.0f));
    auto zero = Vec3(0.0, 0.0f, 0.0f);
    assert(-zero == zero);

    // opBinary "+"
    const auto v2 = Vec3(4.0f, 5.0f, 6.0f);
    const auto v_add = v1 + v2;
    assert(v_add == Vec3(5.0f, 7.0f, 9.0f));
    assert(v1 + zero == v1);

    // opBinary "-"
    const auto v_sub = v2 - v1;
    assert(v_sub == Vec3(3.0f, 3.0f, 3.0f));
    assert(v1 - v1 == zero);

    // opBinary "*", opBinaryRight "*"
    const auto v_mul = v1 * 2.0f;
    assert(v_mul == Vec3(2.0f, 4.0f, 6.0f));
    assert(2.0f * v1 == Vec3(2.0f, 4.0f, 6.0f));
    assert(v1 * 0.0f == zero);

    // opBinary "/"
    const auto v_div = v1 / 2.0f;
    assert(v_div == Vec3(0.5f, 1.0f, 1.5f));

    // norm
    auto v3 = Vec3(3.0f, 4.0f, 0.0f);
    assert(fequals(v3.norm(), 5.0f));
    assert(fequals(Vec3(1.0f, 0.0f, 0.0f).norm(), 1.0f));
    assert(fequals(zero.norm(), 0.0f));
    auto v_len_test = Vec3(1.0f, 1.0f, 1.0f);
    assert(fequals(v_len_test.norm(), sqrt(3.0f)));

    // normalized
    auto v3_norm = v3.normalized();
    assert(v3_norm == Vec3(0.6f, 0.8f, 0.0f));
    assert(fequals(v3_norm.norm(), 1.0f));
    auto v_axis = Vec3(10.0f, 0.0f, 0.0f);
    assert(v_axis.normalized() == Vec3(1.0f, 0.0f, 0.0f));

    // dot
    auto v_dot1 = Vec3(1.0f, 2.0f, 3.0f);
    auto v_dot2 = Vec3(4.0f, -5.0f, 6.0f);
    assert(fequals(v_dot1.dot(v_dot2), 1.0f*4.0f + 2.0f*(-5.0f) + 3.0f*6.0f)); // 4 - 10 + 18 = 12
    assert(fequals(v_dot1.dot(v_dot2), 12.0f));
    assert(fequals(v_dot1.dot(zero), 0.0f));
    assert(fequals(v_dot1.dot(v_dot2), v_dot2.dot(v_dot1)));
    auto v_ortho1 = Vec3(1.0f, 0.0f, 0.0f);
    auto v_ortho2 = Vec3(0.0f, 1.0f, 0.0f);
    assert(fequals(v_ortho1.dot(v_ortho2), 0.0f));
    assert(fequals(v3.dot(v3), v3.norm() * v3.norm()));

    // cross
    auto v_cross1 = Vec3(1.0f, 0.0f, 0.0f);
    auto v_cross2 = Vec3(0.0f, 1.0f, 0.0f);
    auto v_cross3 = Vec3(0.0f, 0.0f, 1.0f);
    assert(v_cross1.cross(v_cross2) == v_cross3);
    assert(v_cross2.cross(v_cross1) == -v_cross3);
    assert(v_cross2.cross(v_cross3) == v_cross1);
    assert(v_cross3.cross(v_cross2) == -v_cross1);
    assert(v_cross3.cross(v_cross1) == v_cross2);
    assert(v_cross1.cross(v_cross3) == -v_cross2);
    assert(v1.cross(v1) == zero);
    auto v_c1 = Vec3(2.0f, 3.0f, 4.0f);
    auto v_c2 = Vec3(5.0f, 6.0f, 7.0f);
    const auto v_c_res = Vec3(3.0f*7.0f - 4.0f*6.0f, 4.0f*5.0f - 2.0f*7.0f, 2.0f*6.0f - 3.0f*5.0f);
    assert(v_c1.cross(v_c2) == v_c_res);
    assert(v_c1.cross(v_c2) == Vec3(-3.0f, 6.0f, -3.0f));

    // distance
    auto v_dist1 = Vec3(1.0f, 2.0f, 3.0f);
    auto v_dist2 = Vec3(4.0f, 6.0f, 3.0f);
    assert(fequals(v_dist1.distance(v_dist2), 5.0f));
    assert(fequals(v_dist1.distance(v_dist1), 0.0f));
    assert(fequals(v_dist1.distance(zero), v_dist1.norm()));

	// Ray
    auto o = Vec3(0.0f, 0.0f, 0.0f);
	auto x_axis = Vec3(1.0f, 0.0f, 0.0f);
	auto y_axis = Vec3(0.0f, 1.0f, 0.0f);
	auto z_axis = Vec3(0.0f, 0.0f, 1.0f);
	const auto r1 = Ray(o, x_axis);
	assert(r1.origin == o);
	assert(r1.direction == x_axis);
	const auto r2 = Ray(o, Vec3(5.0f, 0.0f, 0.0f));
	assert(r2.direction == x_axis);
	const auto r3 = Ray(Vec3(1.0f, 2.0f, 3.0f), Vec3(1.0f, 1.0f, 1.0f));
	assert(r3.origin == Vec3(1.0f, 2.0f, 3.0f));

	// at
	auto r4 = Ray(o, x_axis);
	assert(r4.at(0.0f) == o);
	assert(r4.at(5.0f) == Vec3(5.0f, 0.0f, 0.0f));
	assert(r4.at(-5.0f) == Vec3(-5.0f, 0.0f, 0.0f));
	auto r5 = Ray(Vec3(1.0f, 1.0f, 1.0f), y_axis);
	assert(r5.at(3.0f) == Vec3(1.0f, 4.0f, 1.0f));

	// distanceToPoint
	auto r6 = Ray(o, x_axis);
	assert(fequals(r6.distanceToPoint(Vec3(10.0f, 0.0f, 0.0f)), 0.0f));
	assert(fequals(r6.distanceToPoint(o), 0.0f));
	assert(fequals(r6.distanceToPoint(Vec3(5.0f, 3.0f, 0.0f)), 3.0f));
	assert(fequals(r6.distanceToPoint(Vec3(5.0f, 3.0f, 4.0f)), 5.0f));
	assert(fequals(r6.distanceToPoint(Vec3(-5.0f, 3.0f, 4.0f)), Vec3(-5.0f, 3.0f, 4.0f).norm()));
	auto r7 = Ray(Vec3(1.0f, 1.0f, 0.0f), y_axis);
	assert(fequals(r7.distanceToPoint(Vec3(1.0f, 5.0f, 0.0f)), 0.0f));
	assert(fequals(r7.distanceToPoint(Vec3(1.0f, -5.0f, 0.0f)), 6.0f));
	assert(fequals(r7.distanceToPoint(Vec3(4.0f, 5.0f, 0.0f)), 3.0f));

	// angleToRay
	auto r_x = Ray(o, x_axis);
	auto r_y = Ray(o, y_axis);
	auto r_z = Ray(o, z_axis);
	auto r_neg_x = Ray(o, -x_axis);
	auto r_45 = Ray(o, Vec3(1.0f, 1.0f, 0.0f));
	assert(fequals(r_x.angleToRay(r_x), 0.0f));
	assert(fequals(r_x.angleToRay(r_neg_x), PI));
	assert(fequals(r_x.angleToRay(r_y), PI / 2.0f));
	assert(fequals(r_x.angleToRay(r_z), PI / 2.0f));
	assert(fequals(r_y.angleToRay(r_z), PI / 2.0f));
	assert(fequals(r_x.angleToRay(r_45), PI / 4.0f));
	assert(fequals(r_y.angleToRay(r_45), PI / 4.0f));
	auto r_almost_x = Ray(o, Vec3(1.0f, 1e-7f, 0.0f));
	assert(fequals(r_x.angleToRay(r_almost_x), 0.0f, 1e-6f));
	auto r_almost_neg_x = Ray(o, Vec3(-1.0f, 1e-7f, 0.0f));
	assert(fequals(r_x.angleToRay(r_almost_neg_x), PI, 1e-6f));
}
