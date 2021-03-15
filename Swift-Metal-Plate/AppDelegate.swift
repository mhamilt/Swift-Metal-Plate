import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        if let window = NSApplication.shared.mainWindow
        {
            window.setContentSize(NSSize(width: 800, height: 600))
            window.minSize = NSSize(width: 800, height: 600)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
    }
}

