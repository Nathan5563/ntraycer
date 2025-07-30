module lib.math.ray;

import lib.math.vec3 : Vec3;
import lib.math.utils : acos;

struct Ray
{
	Vec3 origin;
	Vec3 direction;

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

// TODO: UNIT TESTS
