//
//  ViewController.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController
{
    
    // Outlets for the views in the Storyboard
    @IBOutlet var splitView: NSSplitView!
    @IBOutlet weak var mtkView: MTKView!

    // The delegate of the MTKView that does the drawing
    var renderer: Renderer!
    
    // Used to construct the shapePopUpButton
    private let shapes = ["Triangle", "Cube"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set up the NSSplitView
        splitView.setPosition(250.0, ofDividerAt: 0)
        splitView.setHoldingPriority(.defaultHigh, forSubviewAt: 0)
        
        // Get the default GPU and assign it to the MTKView
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create default Metal device")
        }
        mtkView.device = defaultDevice
        
        // When the MTKView is cleared between frames set it to black
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Create the renderer object and set it as the MTKView delegate
        guard let tmpRenderer = Renderer(mtkView: self.mtkView) else {
            fatalError("Could not initialise Renderer class")
        }
        renderer = tmpRenderer
        
        mtkView.delegate = renderer
        
        // Set the initial shape to be drawn
        renderer.setModel()
//        renderer.model = Model(numberOfGridPoints: 100)
        
        // Get the scale value
        let scale = 2.0 as Float
        
        // Not implemented yet - translation value
        let translation: float3 = [0.0, 0.0, 0.0]
        
        // Not implemented yet - rotation around X, Y, and Z
        let rx: float_t = 0.0
        let ry: float_t = 0.0
        let rz: float_t = 0.0
        
        // Set transformationMatrix
        renderer.uniforms.modelMatrix = float4x4.createTransformationMatrix(translation: translation,
                                                                            rx: rx, ry: ry, rz: rz,
                                                                            scale: scale)
    }
}

