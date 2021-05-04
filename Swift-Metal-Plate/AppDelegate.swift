import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        if let window = NSApplication.shared.mainWindow
        {
            window.setContentSize(NSSize(width: 500, height: 500))
            window.minSize = NSSize(width: 450, height: 450)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
    
}

