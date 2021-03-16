import MetalKit

struct Model
{
    /// The vertices that make up the shape
    var vertices: [Vertex]!
    private var plateVertexData: [Vertex?] = []
    var plateInidices:[uint16] = []
    private let rows: Int!
    private let columns: Int!
    
    ///    private let plateVertexData: [Vertex]
    /// The order in which the vertices should be drawn, as triangles
    /// Note that by default Metal expects triangles to be described as a clockwise list of vertsices
    private var indices: [uint16]?
    
    /// Number of indices that make up the shape
    var count: Int!
    
    init(numberOfGridPoints: Int)
    {
        rows = Int(sqrt(Float(numberOfGridPoints)))
        columns = rows
        setPlateVertices()
        self.vertices = (self.plateVertexData as! [Vertex])
        self.indices = self.plateInidices
        self.count = self.indices?.count
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
        guard let indexBuffer = device.makeBuffer(bytes: indices!,
                                                  length: indices!.count * MemoryLayout<uint16>.size,
                                                  options: []) else {
                                                    fatalError("Could not create MTLBuffer")
        }
        
        
        
        return indexBuffer
    }
    
    /// Set up a grid of vertices and organise the order for drawing triangles
    mutating func setPlateVertices()
    {
        let xScale:Float = 2.0/Float(rows)
        let yScale:Float = 2.0/Float(columns)
        
        self.plateVertexData = [Vertex?](repeating: nil,
                                         count: rows*columns)
        for y in 0..<columns
        {
            for x in 0..<rows
            {
                let i = (x + y*rows);
                
                plateVertexData[i] = Vertex(pos: [-1.0 + Float(x)*xScale,
                                                  -1.0 + Float(y)*yScale,
                                                  0],
                                            col: [Float(x)*xScale, Float(y)*yScale, Float(x)*xScale*Float(y)*yScale])
            }
        }
        let nx = uint16(rows)
        let xRange = CountableRange<uint16>(uncheckedBounds: (lower: 0, upper: nx-1))
        
        for y in 0..<(columns-1)
        {
            for xp in xRange
            {
                let x:uint16 = xp + uint16(y)*nx
                plateInidices.append(x)
                plateInidices.append(x+nx)
                plateInidices.append(x+1)
                plateInidices.append(x+1)
                plateInidices.append(x+nx)
                plateInidices.append(x+nx+1)
            }
        }
        
    }
    
}
