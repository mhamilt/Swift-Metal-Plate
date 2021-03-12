//
//  MetalCommon.h
//  Hello Metal
//
//  Created by mhamilt7 on 12/03/2021.
//  Copyright © 2021 Passback Systems. All rights reserved.
//

#ifndef MetalCommon_h
#define MetalCommon_h
#include <simd/simd.h>
// Define the structure of a vertex as:
//  - position vector or three floats representing the x, y, and z coordinates
//  - colour vector of three floats representing red, green, and blue values

struct Vertex {
    vector_float3 pos;
    vector_float3 col;
};
#endif /* MetalCommon_h */
