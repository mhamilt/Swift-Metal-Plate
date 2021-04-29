import MetalKit
import simd

struct Uniforms
{
    var modelMatrix = matrix_identity_float4x4
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var wireframe = false
};

class Renderer: NSObject
{
    //----------------------------------------------------------------------
    // Core Metal Objects
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    //----------------------------------------------------------------------
    // The vertices and indices that will be drawn
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    //----------------------------------------------------------------------
    // Setting up the model
    var plate: UnsafeMutableRawPointer! = nil
    var colourChange: Float32 = 0.5
    var colourArray:[Float32]!
    var stateBuffer: MTLBuffer!
    var model: Model?
    {
        didSet
        {
            vertexBuffer = model?.getVertexBuffer(device: device)
            indexBuffer = model?.getIndexBuffer(device: device)
        }
    }
    
    var uniforms = Uniforms()
    
    init?(mtkView: MTKView)
    {
        plate = makePlate()
        
        guard let tmpDevice = mtkView.device else { return nil }
        self.device = tmpDevice
        guard let tmpCommandQueue = device.makeCommandQueue() else { return nil }
        commandQueue = tmpCommandQueue
        
        pipelineState = Renderer.createRenderPipeline(mtkView: mtkView)
        
        uniforms.modelMatrix = matrix_identity_float4x4
        uniforms.viewMatrix = float4x4.createTranslationMatrix(translation: [0, 0, -3]).inverse
        
        let aspect = Float(mtkView.bounds.width / mtkView.bounds.height)
        let FOV = (70 / 180) * Float.pi
        uniforms.projectionMatrix = Renderer.createProjectionMatrix(fov: FOV,
                                                                    near: 0.01,
                                                                    far: 100.0,
                                                                    aspect: aspect)
    }
    
    class func createRenderPipeline(mtkView: MTKView) -> MTLRenderPipelineState
    {
        let library = mtkView.device?.makeDefaultLibrary()  // Shaders.metal
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        guard let pipelineState = try! mtkView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Could not make RenderPipelineState")
        }
        return pipelineState
    }
    
    class func createProjectionMatrix(fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) -> matrix_float4x4 {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = SIMD4<Float>( x,  0,  0,  0)
        let Y = SIMD4<Float>( 0,  y,  0,  0)
        let Z = lhs ? SIMD4<Float>( 0,  0,  z, 1) : SIMD4<Float>( 0,  0,  z, -1)
        let W = lhs ? SIMD4<Float>( 0,  0,  z * -near,  0) : SIMD4<Float>( 0,  0,  z * near,  0)
        return matrix_float4x4(X, Y, Z, W)
    }
    
    func setModel() {
        self.model = Model(numberOfGridPoints: Int(getGridSize(plate)))
        print("Plate Size: ", Int(getGridSize(plate)))
        stateBuffer = device.makeBuffer(bytes: getCurrentState(plate), length: Int(getGridSize(plate))*4, options: [])
    }
}

extension Renderer: MTKViewDelegate
{
    
    /// Called on window resize
    /// - Parameters:
    ///   - view: MTKView in Question
    ///   - size: <#size description#>
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
        let aspect = Float(view.bounds.width / view.bounds.height)
        let FOV = (70 / 180) * Float.pi
        uniforms.projectionMatrix = Renderer.createProjectionMatrix(fov: FOV, near: 0.01, far: 100.0, aspect: aspect)
    }
    
    
    /// Main Metal Draw Loop
    /// - Parameter view: MTKView
    func draw(in view: MTKView)
    {
        //----------------------------------------------------------------------
        // Stuff We have to do
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { fatalError("Could not create commandBuffer") }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { fatalError("Could not get renderPassDescriptor") }
        guard let vertexBuffer = self.vertexBuffer else { fatalError("Could not get vertexBuffer") }
        guard let indexBuffer = self.indexBuffer else { fatalError("Could not get indexBuffer") }
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { fatalError("Could not create renderEncoder") }
        renderEncoder.setRenderPipelineState(pipelineState)
        //----------------------------------------------------------------------
        // Setting up Uniforms, buffers and vertices
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setVertexBytes(&colourChange, length: MemoryLayout<Float32>.size, index: 2)
        
        for _ in 0...5
        {
            updateScheme(plate)
        }
        
        stateBuffer = device.makeBuffer(bytes: getCurrentState(plate),
                                        length: Int(getGridSize (plate))*MemoryLayout<Float32>.size,
                                        options: [])
        renderEncoder.setVertexBuffer(stateBuffer, offset: 0, index: 3)
        //----------------------------------------------------------------------
        // Styling
        renderEncoder.setTriangleFillMode(.fill)
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: model!.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        //----------------------------------------------------------------------
        // Commit Render
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
