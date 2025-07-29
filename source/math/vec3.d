module math.vec3;

import math.utils;

struct Vec3
{
	float x, y, z;

	this()
	{
		this.x = 0;
		this.y = 0;
		this.z = 0;
	}
	this(float x, float y, float z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	Vec3 clone() const
	{
		return Vec3(this.x, this.y, this.z);
	}

	// TODO: OVERRIDE OPERATIONS
	//       equals, sum, difference with other Vec3
	//       product, quotient with float
	//       negate

	float norm() const
	{
		return sqrt(pow(this.x, 2) + pow(this.y, 2) + pow(this.z, 2));
	}
	Vec3 normalized() const
	{
		return this * inverseSqrt(pow(this.x, 2) + pow(this.y, 2) + pow(this.z, 2));
	}
	float dot(Vec3 v) const
	{
		return this.x * v.x + this.y * v.y + this.z * v.z;
	}
	Vec3 cross(Vec3 v) const
	{
		Vec3 res;
		res.x = this.y * v.z - this.z * v.y;
		res.y = this.z * v.x - this.x * v.z;
		res.z = this.x * v.y - this.y * v.x;
		return res;
	}
	float distance(Vec3 v) const
	{
		return sqrt(pow(this.x - v.x, 2) + pow(this.y - v.y, 2) + pow(this.z - v.z, 2));
	}
}

// TODO: UNIT TESTS
