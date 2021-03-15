#include <metal_stdlib>
#include "MetalCommon.h"

using namespace metal;


struct VertexOut
{
    float4 pos [[position]];
    float3 col;
};


struct Uniforms
{
    matrix_float4x4  modelMatrix;
    matrix_float4x4  viewMatrix;
    matrix_float4x4  projectionMatrix;
    bool wireframe;
};

constant float scaling = 10.0;

vertex VertexOut vertex_main(const device Vertex *vertexArray [[buffer(0)]],
                             unsigned int vid [[vertex_id]],
                             constant Uniforms &uniforms [[buffer(1)]],
                             constant float &testValue,
                             constant float* colourArray)
{
    Vertex in = vertexArray[vid];
    VertexOut out;
    
    out.pos = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(in.pos, 1);

    float vertexDisplacement = colourArray[vid] * scaling;
    float3 posColour = clamp(vertexDisplacement*float3(1.0, 1.0, 0.0),
                             float3(0.0, 0.0, 0.0),
                             float3(4.0, 4.0, 0.0));
    float3 negColour = clamp((-vertexDisplacement)*float3(0.0, 1.0, 1.0),
                             float3(0.0, 0.0, 0.0),
                             float3(0.0, 4.0, 4.0));
    out.col = posColour + negColour;
    
    return out;
}

// Pass through fragment shader
fragment float4 fragment_main(VertexOut in [[stage_in]])
{
    return float4(in.col, 1);
}

