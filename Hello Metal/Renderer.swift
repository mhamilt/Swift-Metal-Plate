//
//  Renderer.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import MetalKit
import simd

// Switch to defining Unforms in Swift and MSL rather than bridging
// Managing types was getting tricky
struct Uniforms {
    var modelMatrix = matrix_identity_float4x4
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var wireframe = false
};

class Renderer: NSObject {
    
    // Core Metal objects set up in advance of drawing
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    var plate: UnsafeMutableRawPointer! = nil
    // The vertices and indices that will be drawn
    private var vertexBuffer: MTLBuffer?
    private var indexBuffer: MTLBuffer?
    var colourChange: Float32 = 0.0
    // The model that will be drawn, create the vertex and index buffers when
    // the model is changed
    var model: Model? {
        didSet {
            vertexBuffer = model?.getVertexBuffer(device: device)
            indexBuffer = model?.getIndexBuffer(device: device)
        }
    }
    
    // Contains the model, view, and projection matrices; and a boolean to toggle wireframe rendering
    var uniforms = Uniforms()
    
    init?(mtkView: MTKView) {
        plate = makePlate()
        // Get the device for convenience
        guard let tmpDevice = mtkView.device else {
            return nil
        }
        self.device = tmpDevice
        
        // Create the CommandQueue
        guard let tmpCommandQueue = device.makeCommandQueue() else {
            return nil
        }
        commandQueue = tmpCommandQueue
        
        // Create the RenderPipelineState
        pipelineState = Renderer.createRenderPipeline(mtkView: mtkView)
        
        // Initialise the model matrix to the identity matrix
        uniforms.modelMatrix = matrix_identity_float4x4
        
        // Set the camera three units away from the scene
        uniforms.viewMatrix = float4x4.createTranslationMatrix(translation: [0, 0, -3]).inverse
        
        // Initialise the projection matrix to the identity matrix
        let aspect = Float(mtkView.bounds.width / mtkView.bounds.height)
        let FOV = (70 / 180) * Float.pi
        uniforms.projectionMatrix = Renderer.createProjectionMatrix(fov: FOV, near: 0.01, far: 100.0, aspect: aspect)
        
        
    }
    
    class func createRenderPipeline(mtkView: MTKView) -> MTLRenderPipelineState {
        // Get the default shader library - this is the compiled version of Shaders.metal
        let library = mtkView.device?.makeDefaultLibrary()
        
        // Configure the shaders we want to use and the pixelFormat
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        // Create and return the RenderPipelineState, or crash with a fatal error
        guard let ps = try! mtkView.device?.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            fatalError("Could not make RenderPipelineState")
        }
        return ps
    }
    
    class func createProjectionMatrix(fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) -> matrix_float4x4 {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = float4( x,  0,  0,  0)
        let Y = float4( 0,  y,  0,  0)
        let Z = lhs ? float4( 0,  0,  z, 1) : float4( 0,  0,  z, -1)
        let W = lhs ? float4( 0,  0,  z * -near,  0) : float4( 0,  0,  z * near,  0)
        return matrix_float4x4(X, Y, Z, W)
    }
    func setModel() {
        self.model = Model(numberOfGridPoints: 1000)
    }
}

extension Renderer: MTKViewDelegate {
    // Called when the MTKView changes size so we recalculate the projection matrix
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(view.bounds.width / view.bounds.height)
        let FOV = (70 / 180) * Float.pi
        uniforms.projectionMatrix = Renderer.createProjectionMatrix(fov: FOV, near: 0.01, far: 100.0, aspect: aspect)
    }
    
    // Called 60 times a second to update the contents of the MTKView
    func draw(in view: MTKView) {
        // Create a CommandBuffer and a RenderPassDescriptor
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        updateScheme(plate)
        // Check we've got something to draw
//        if let numVertices = model?.vertices.count
//        {
//
//            for i in 0..<numVertices
//            {
//                model!.vertices[i].col = [colourChange,0.0,0.0]
//            }
//        }
        
        guard let vertexBuffer = self.vertexBuffer else { return }
        guard let indexBuffer = self.indexBuffer else { return }
        
        // Create the RenderCommandEncoder
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Set the pipeline state, i.e. tell the GPU which shader functions to use
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Tell the GPU which vertices we want to draw
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Not used yet, tell the GPU about the uniforms
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        
        // Configure wireframe or fill/solid rendering
        renderEncoder.setTriangleFillMode(uniforms.wireframe ? .lines : .fill)
        
        // Draw the vertices as triangles in the order specified by the indices array of the model
        // which is encoded in the indexBuffer
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: model!.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        
        // Finish encoding commands for the GPU and tell it to do some rendering to the MTKView
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
}
