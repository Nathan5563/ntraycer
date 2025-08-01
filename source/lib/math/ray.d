module lib.math.ray;

import lib.math.vec : Vec3;
import lib.math.utils : acos;

struct Ray
{
	Vec3 origin, direction;

	this(const Vec3 origin, const Vec3 direction)
	{
		this.origin = origin;
		this.direction = direction.normalized();
	}

	Vec3 at(const float time) const
	{
		return origin + direction * time;
	}
	float distanceToPoint(const Vec3 point) const
	{
		float time = direction.dot(point - origin);
		if (time < 0)
		{
			time = 0;
		}
		Vec3 closestPoint = origin + direction * time;
		return (closestPoint - point).norm();
	}
	float angleToRay(const Ray r) const
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
	import lib.math.utils : fequals, PI, sqrt;

	auto o = Vec3(0.0f, 0.0f, 0.0f);
	auto x_axis = Vec3(1.0f, 0.0f, 0.0f);
	auto y_axis = Vec3(0.0f, 1.0f, 0.0f);
	auto z_axis = Vec3(0.0f, 0.0f, 1.0f);

	// this
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
