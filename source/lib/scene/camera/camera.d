// COMPLETE, ADD DOCS
module lib.scene.camera.camera;

import lib.core.math : Vec2, Vec3, Ray;

interface Camera
{
    Vec3 position() const;
    Ray getRay(Vec2 coord) const;
}
