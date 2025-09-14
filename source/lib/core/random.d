module lib.core.random;

import lib.core.math : Vec3;

private uint state = 1u;

void srand(uint seed)
{
    state = seed;
}

uint randu()
{
    state = 1664525u * state + 1013904223u;
    return state;
}

float randf()
{
    return cast(float)(randu() & 0x00FFFFFFu) / 16777216.0f;
}

Vec3 randomInUnitSphere()
{
    while (true)
    {
        Vec3 p = Vec3(randf() * 2.0f - 1.0f,
                      randf() * 2.0f - 1.0f,
                      randf() * 2.0f - 1.0f);
        if (p.dot(p) >= 1.0f)
        {
            continue;
        }
        return p;
    }
}

Vec3 randomUnitVector()
{
    return randomInUnitSphere().normalized();
}

