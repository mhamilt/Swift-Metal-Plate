import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        if let window = NSApplication.shared.mainWindow
        {
            window.setContentSize(NSSize(width: 700, height: 700))
            window.minSize = NSSize(width: 650, height: 650)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
    }
}

