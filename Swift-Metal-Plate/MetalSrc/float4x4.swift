import simd

extension float4x4
{
    static func createTransformationMatrix(translation: SIMD3<Float>,
                                           rx: float_t, ry: float_t, rz: float_t,
                                           scale: float_t) -> float4x4
    {
        let scaleMatrix = createScaleMatrix(scale: scale)
        let translationMatrix = createTranslationMatrix(translation: translation)
        
        return scaleMatrix * translationMatrix
    }
        
    static func createScaleMatrix(scale: float_t) -> float4x4
    {
        var matrix = matrix_identity_float4x4
        
        matrix.columns.0.x = scale
        matrix.columns.1.y = scale
        matrix.columns.2.z = scale
        
        return matrix
    }
        
    static func createTranslationMatrix(translation: SIMD3<Float>) -> float4x4
    {
        var matrix = matrix_identity_float4x4
        
        matrix.columns.3.x = translation.x
        matrix.columns.3.y = translation.y
        matrix.columns.3.z = translation.z
        
        return matrix
    }
}
