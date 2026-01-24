// COMPLETE
/**
 * This module defines the Camera interface used to generate rays for rendering.
 * Different camera implementations provide different projection models.
 */
module lib.scene.camera.camera;

import lib.core.math : Vec2, Vec3, Ray;

/// @interface Camera - Interface for camera implementations
interface Camera
{
    /// @func position - Returns the camera's position in world space
    ///
    /// @returns - the camera origin point
    Vec3 position() const;

    /// @func getRay - Generates a ray for the given screen coordinates
    ///
    /// @param coord - normalized screen coordinates (0-1 range for u and v)
    ///
    /// @returns - a ray from the camera through the specified screen point
    Ray getRay(Vec2 coord) const;
}
