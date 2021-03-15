import Cocoa
import MetalKit

class ViewController: NSViewController
{
    @IBOutlet weak var mtkView: MTKView!

    var renderer: Renderer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Could not create default Metal device")
        }
        mtkView.device = defaultDevice

        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
        guard let tmpRenderer = Renderer(mtkView: self.mtkView) else {
            fatalError("Could not initialise Renderer class")
        }
        renderer = tmpRenderer
        mtkView.delegate = renderer
        renderer.setModel()

        let scale = 2.0 as Float
        
        let translation: SIMD3<Float> = [0.0, 0.0, 0.0]
        let rx: float_t = 0.0
        let ry: float_t = 0.0
        let rz: float_t = 0.0
                
        renderer.uniforms.modelMatrix = float4x4.createTransformationMatrix(translation: translation,
                                                                            rx: rx, ry: ry, rz: rz,
                                                                            scale: scale)
    }
}
