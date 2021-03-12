//
//  float4x4.swift
//  Hello Metal
//
//  Created by Keith Sharp on 21/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import simd

extension float4x4 {
    
    // Create a transformation matrix with a
    //  - translation to a location in world space
    //  - rotation around the X, Y, and Z axis
    //  - size scaling
    static func createTransformationMatrix(translation: float3, rx: float_t, ry: float_t, rz: float_t, scale: float_t) -> float4x4 {
        let scaleMatrix = createScaleMatrix(scale: scale)
        let translationMatrix = createTranslationMatrix(translation: translation)
        
        return scaleMatrix * translationMatrix
    }
    
    // Create a scaling matrix, same scale on all axis
    static func createScaleMatrix(scale: float_t) -> float4x4 {
        var matrix = matrix_identity_float4x4
        
        matrix.columns.0.x = scale
        matrix.columns.1.y = scale
        matrix.columns.2.z = scale
        
        return matrix
    }
    
    // Create a translation matrix - used for the camera position (view matrix)
    static func createTranslationMatrix(translation: float3) -> float4x4 {
        var matrix = matrix_identity_float4x4
        
        matrix.columns.3.x = translation.x
        matrix.columns.3.y = translation.y
        matrix.columns.3.z = translation.z
        
        return matrix
    }
}
