//
//  AppDelegate.swift
//  Hello Metal
//
//  Created by Keith Sharp on 20/05/2019.
//  Copyright © 2019 Passback Systems. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set a minimum size for the main window
        if let window = NSApplication.shared.mainWindow {
            window.setContentSize(NSSize(width: 800, height: 600))
            window.minSize = NSSize(width: 800, height: 600)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

