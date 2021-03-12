//
//  Model.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import MetalKit

// What type of shape do we want to model
enum Shape: Int {
    case triangle
    case cube
}

struct Model
{
    // The vertices that make up the shape
    var vertices: [Vertex]!
    private var plateVertexData: [Vertex?] = []
    var plateInidices:[uint16] = []
    private let rows: Int = 10
    private let columns: Int = 10
    //    private let plateVertexData: [Vertex]
    // The order in which the vertices should be drawn, as triangles
    // Note that by default Metal expects triangles to be described as a clockwise list of vertsices
    private var indices: [uint16]!
    
    // Number of indices that make up the shape
    var count: Int!
    
    init(numberOfGridPoints: Int)
    {
        setPlateVerticies()
        self.vertices = (self.plateVertexData as! [Vertex])
        self.indices = self.plateInidices
        self.count = self.indices.count
    }
    
    /// Convert the vertices to an MTLBuffer on the GPU
    func getVertexBuffer(device: MTLDevice) -> MTLBuffer {
        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: []) else {
            fatalError("Could not create MTLBuffer")
        }
        return vertexBuffer
    }
    
    /// Convert the indeices to an MTLBuffer on the GPU
    func getIndexBuffer(device: MTLDevice) -> MTLBuffer {
        guard let indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<uint>.stride, options: []) else {
            fatalError("Could not create MTLBuffer")
        }
        return indexBuffer
    }
    
    mutating func setPlateVerticies()
    {
        self.plateVertexData = [Vertex?](repeating: nil,
                                         count: rows*columns*6)
        
        let xScale:Float = 2.0/Float(rows)
        let yScale:Float = 2.0/Float(columns)
        
        for y in 0..<columns
        {
            for x in 0..<rows
            {
                let i = (x + y*rows)*6;
                
                plateInidices.append(uint16(i) )
                plateVertexData[i] = Vertex(pos: [-1.0 + Float(x)*xScale,
                                                  -1.0 + Float(y)*yScale,
                                                  0],
                                            col: [1.0, 0.0, 0.0])
                plateInidices.append(uint16(i+1))
                plateVertexData[i+1]   = Vertex(pos: [-1.0 + Float(x+1)*xScale,
                                                      -1.0 + Float(y)*yScale,
                                                      0],
                                                col: [0.0, 1.0, 0.0])
                plateInidices.append(uint16(i+2))
                plateVertexData[i+2]   = Vertex(pos: [-1.0 + Float(x)*xScale,
                                                      -1.0 + Float(y+1)*yScale,
                                                      0],
                                                col: [0.0, 0.0, 1.0])
                plateInidices.append(uint16(i+3))
                plateVertexData[i+3]   = plateVertexData[i+1]
                plateInidices.append(uint16(i+4))
                plateVertexData[i+4]   = plateVertexData[i+2]
                plateInidices.append(uint16(i+5))
                plateVertexData[i+5]   = Vertex(pos: [-1.0 + Float(x+1)*xScale,
                                                      -1.0 + Float(y+1)*yScale,
                                                      0],
                                                col: [1.0, 0.0, 0.0])
                
            }
        }
    }
    
}
