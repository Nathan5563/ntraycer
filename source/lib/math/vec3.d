module lib.math.vec3;

import lib.math.utils : sqrt, inverseSqrt, fequals, EPSILON;

struct Vec3
{
	float x;
	float y;
	float z;

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

    bool opEquals(const Vec3 rhs) const
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
		return sqrt(
			(this.x - v.x) * (this.x - v.x) +
            (this.y - v.y) * (this.y - v.y) +
            (this.z - v.z) * (this.z - v.z)
		);
	}
}

unittest
{
    // this, clone, opBinary "=="
    auto v1 = Vec3(1.0f, 2.0f, 3.0f);
    assert(v1.x == 1.0f && v1.y == 2.0f && v1.z == 3.0f);
    auto v1_clone = v1.clone();
    assert(v1 == v1_clone);

    // opUnary "-", opBinary "=="
    auto v_neg = -v1;
    assert(v_neg == Vec3(-1.0f, -2.0f, -3.0f));
    auto zero = Vec3(0.0, 0.0f, 0.0f);
    assert(-zero == zero);

    // opBinary "=="
    assert(Vec3(1.0f, 2.0f, 3.0f) == Vec3(1.0f, 2.0f, 3.0f));
    assert(Vec3(1.0f, 2.0f, 3.0f) != Vec3(3.0f, 2.0f, 1.0f));
    assert(Vec3(1.0f, 1.0f, 1.0f) == Vec3(1.0f + EPSILON/2, 1.0f + EPSILON/2, 1.0f + EPSILON/2));
    assert(Vec3(1.0f, 1.0f, 1.0f) != Vec3(1.0f + EPSILON*2, 1.0f + EPSILON*2, 1.0f + EPSILON*2));

    // opBinary "+", opBinary "=="
    auto v2 = Vec3(4.0f, 5.0f, 6.0f);
    auto v_add = v1 + v2;
    assert(v_add == Vec3(5.0f, 7.0f, 9.0f));
    assert(v1 + zero == v1);

    // opBinary "-", opBinary "=="
    auto v_sub = v2 - v1;
    assert(v_sub == Vec3(3.0f, 3.0f, 3.0f));
    assert(v1 - v1 == zero);

    // opBinary "*", opBinaryRight "*", opBinary "=="
    auto v_mul = v1 * 2.0f;
    assert(v_mul == Vec3(2.0f, 4.0f, 6.0f));
    assert(2.0f * v1 == Vec3(2.0f, 4.0f, 6.0f));
    assert(v1 * 0.0f == zero);

    // opBinary "/", opBinary "=="
    auto v_div = v1 / 2.0f;
    assert(v_div == Vec3(0.5f, 1.0f, 1.5f));

    // norm
    auto v3 = Vec3(3.0f, 4.0f, 0.0f);
    assert(fequals(v3.norm(), 5.0f));
    assert(fequals(Vec3(1.0f, 0.0f, 0.0f).norm(), 1.0f));
    assert(fequals(zero.norm(), 0.0f));
    auto v_len_test = Vec3(1.0f, 1.0f, 1.0f);
    assert(fequals(v_len_test.norm(), sqrt(3.0f)));

    // normalized, opBinary "==", norm
    auto v3_norm = v3.normalized();
    assert(v3_norm == Vec3(0.6f, 0.8f, 0.0f));
    assert(fequals(v3_norm.norm(), 1.0f));
    auto v_axis = Vec3(10.0f, 0.0f, 0.0f);
    assert(v_axis.normalized() == Vec3(1.0f, 0.0f, 0.0f));

    // dot, norm
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

    // cross, opBinary "==", opUnary "-"
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
    auto v_c_res = Vec3(3.0f*7.0f - 4.0f*6.0f, 4.0f*5.0f - 2.0f*7.0f, 2.0f*6.0f - 3.0f*5.0f);
    assert(v_c1.cross(v_c2) == v_c_res);
    assert(v_c1.cross(v_c2) == Vec3(-3.0f, 6.0f, -3.0f));

    // distance, fequals, norm
    auto v_dist1 = Vec3(1.0f, 2.0f, 3.0f);
    auto v_dist2 = Vec3(4.0f, 6.0f, 3.0f);
    assert(fequals(v_dist1.distance(v_dist2), 5.0f));
    assert(fequals(v_dist1.distance(v_dist1), 0.0f));
    assert(fequals(v_dist1.distance(zero), v_dist1.norm()));
}
