// COMPLETE
/**
 * This module defines GPU-friendly data structures for compute shader rendering.
 * These are flat, SOA-compatible representations of scene data that can be
 * uploaded directly to Shader Storage Buffer Objects.
 */
module gpu.scene;

/// GPU-friendly 3D vector (matches GLSL vec3 alignment)
struct GPUVec3
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    float _pad = 0.0f;  // Padding
}

/// Primitive type enum for GPU dispatch
enum GPUPrimitiveType : uint
{
    Sphere = 0,
    Triangle = 1
}

/// Material type enum for GPU dispatch
enum GPUMaterialType : uint
{
    Lambertian = 0,
    Metal = 1,
    Dielectric = 2,
    Emissive = 3
}

/// GPU-friendly primitive representation
struct GPUPrimitive
{
    GPUPrimitiveType type;
    uint materialIndex;
    uint _pad1;
    uint _pad2;

    // Sphere: center in data[0..2], radius in data[3]
    // Triangle: v0 in data[0..2], v1 in data[4..6], v2 in data[8..10]
    float[12] data = 0.0f;
}

/// GPU-friendly material representation (tagged union style)
struct GPUMaterial
{
    GPUMaterialType type;
    float param1;       // fuzz for Metal, ior for Dielectric, intensity for Emissive
    float _pad1;
    float _pad2;
    GPUVec3 albedo;     // albedo or emission color
}

/// GPU-friendly BVH node for stackless traversal
struct GPUBVHNode
{
    GPUVec3 aabbMin;
    GPUVec3 aabbMax;
    int leftChild;      // Index of left child, -1 if leaf
    int rightChild;     // Index of right child, -1 if leaf
    int primStart;      // First primitive index (for leaf nodes)
    int primCount;      // Number of primitives (0 for internal nodes)
}

/// GPU-friendly camera representation
struct GPUCamera
{
    GPUVec3 origin;
    GPUVec3 lowerLeft;
    GPUVec3 horizontal;
    GPUVec3 vertical;
}

/// Complete GPU scene data ready for upload to SSBOs
struct GPUSceneData
{
    GPUPrimitive[] primitives;
    GPUMaterial[] materials;
    GPUBVHNode[] bvhNodes;
    GPUCamera camera;
    GPUVec3 backgroundColor;
    bool hasSolidBackground;
}

/// Helper to convert CPU Vec3 to GPU Vec3
GPUVec3 toGPUVec3(float x, float y, float z)
{
    return GPUVec3(x, y, z, 0.0f);
}
