module math.vec3;

import math.utils : sqrt, inverseSqrt, pow;

struct Vec3
{
	immutable float x;
	immutable float y;
	immutable float z;

	this(const float x, const float y, const float z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	Vec3 clone() const
	{
		return Vec3(this.x, this.y, this.z);
	}

	Vec3 opUnary(string s)() const if (s == "-")
    {
        return Vec3(-this.x, -this.y, -this.z);
    }
	bool opBinary(string op : "=")(const Vec3 rhs) const
	{
		return fequals(this.x, rhs.x) && fequals(this.y, rhs.y) && fequals(this.z, rhs.z);
	}
	Vec3 opBinary(string op : "+")(Vec3 rhs) const
    {
        return Vec3(this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);
    }
	Vec3 opBinary(string op : "-")(Vec3 rhs) const
    {
        return Vec3(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z);
    }
	Vec3 opBinary(string op : "*")(const float rhs) const
	{
		return Vec3(this.x * rhs, this.y  * rhs, this.z * rhs);
	}
	Vec3 opBinary(string op : "/")(const float rhs) const
	{
		return Vec3(this.x / rhs, this.y  / rhs, this.z / rhs);
	}
	Vec3 opBinaryRight(string op : "*")(const float lhs) const
	{
		return Vec3(lhs * this.x, lhs * this.y, lhs * this.z);
	}
	
	float norm() const
	{
		return sqrt(pow(this.x, 2) + pow(this.y, 2) + pow(this.z, 2));
	}
	Vec3 normalized() const
	{
		return this * inverseSqrt(pow(this.x, 2) + pow(this.y, 2) + pow(this.z, 2));
	}
	float dot(const Vec3 v) const
	{
		return this.x * v.x + this.y * v.y + this.z * v.z;
	}
	Vec3 cross(const Vec3 v) const
	{
		return Vec3(
			this.y * v.z - this.z * v.y,
			this.z * v.x - this.x * v.z,
			this.x * v.y - this.y * v.x
		);
	}
	float distance(const Vec3 v) const
	{
		return sqrt(pow(this.x - v.x, 2) + pow(this.y - v.y, 2) + pow(this.z - v.z, 2));
	}
}

// TODO: UNIT TESTS
