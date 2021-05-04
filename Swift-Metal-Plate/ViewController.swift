import Cocoa
import MetalKit
import Carbon.HIToolbox

class ViewController: NSViewController
{
    @IBOutlet weak var mtkView: MTKView!
    
    var renderer: Renderer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {fatalError("Could not create default Metal device")}
        mtkView.device = defaultDevice
        
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        guard let tmpRenderer = Renderer(mtkView: self.mtkView) else {
            fatalError("Could not initialise Renderer class")
        }
        renderer = tmpRenderer
        mtkView.delegate = renderer
        renderer.setModel()
        
        let scale = 2.15 as Float
        
        let translation: SIMD3<Float> = [0.0, 0.0, 0.0]
        let rx: float_t = 0.0
        let ry: float_t = 0.0
        let rz: float_t = 0.0
        
        renderer.uniforms.modelMatrix = float4x4.createTransformationMatrix(translation: translation,
                                                                            rx: rx, ry: ry, rz: rz,
                                                                            scale: scale)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if self.keyDownHandler(with: $0) {
                return nil
            } else {
                return $0
            }
        }
    }
    
    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        let width:  Float = Float(self.view.window!.frame.width)
        let height: Float = Float(self.view.window!.frame.height)
        
        
        addForce(renderer.plate, 1000.0, Float(event.locationInWindow.y) / height, Float(event.locationInWindow.x) / width)
    }
    
    override func rightMouseDown(with event: NSEvent)
    {
        
    }
    func keyDownHandler(with event: NSEvent) -> Bool {
        
        guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return false }
        
        switch (Int(event.keyCode)) {
        case kVK_Space:
            clearStates(renderer.plate);
        case kVK_ANSI_C:
            addForce(renderer.plate, 1000.0, 0.005, 0.005);
            addForce(renderer.plate, 1000.0, 0.995, 0.005);
            addForce(renderer.plate, 1000.0, 0.005, 0.995);
            addForce(renderer.plate, 1000.0, 0.995, 0.995);
        default:
            return false
        }
        return true
    }
    
}

