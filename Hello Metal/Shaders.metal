//
//  Shaders.metal
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

#include <metal_stdlib>
#include "MetalCommon.h"

using namespace metal;

// The data struct that is passed from the vertex shader to the rasteriser to the fragment shader
struct VertexOut {
    float4 pos [[position]]; // Coordinate vector - 4 values to make the matrix math work later
    float3 col; // Colour
};

// The data struct for the uniform variables
struct Uniforms {
    matrix_float4x4  modelMatrix; // Position, rotation, and scale
    matrix_float4x4  viewMatrix; // Camera
    matrix_float4x4  projectionMatrix; // Add 3d perspective
    bool wireframe; // Should we render as a white wireframe
};

constant float scaling = 10.0;

// Pass through vertex shader
vertex VertexOut vertex_main(const device Vertex *vertexArray [[buffer(0)]],
                             unsigned int vid [[vertex_id]],
                             constant Uniforms &uniforms [[buffer(1)]],
                             constant float &testValue,
                             constant float* colourArray)
{
    Vertex in = vertexArray[vid];
    float vertexDisplacement = colourArray[vid] * scaling;
    VertexOut out;
    
    out.pos = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(in.pos, 1);

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

