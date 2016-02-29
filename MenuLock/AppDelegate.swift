//
//  AppDelegate.swift
//  MenuLock
//
//  Created by François Levaux on 29.02.16.
//  Copyright © 2016 François Levaux. All rights reserved.
//

import Cocoa
import MASShortcut


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusBar: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Setup icon
        let icon = NSImage(named: NSImageNameLockLockedTemplate)
        statusItem.image = icon
        statusItem.menu = statusBar
        
        // Setup global keyboard shortcut (CMD + L)
        let keyMask: NSEventModifierFlags = .FunctionKeyMask //[ .AlternateKeyMask, .ShiftKeyMask]
        let keyCode = UInt(0x6F)
        
        let shortcut = MASShortcut(keyCode: keyCode, modifierFlags: keyMask.rawValue)
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: screenSleep)
    }
    
    @IBAction func statusItemQuit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func screenSleep() -> Void {
        let registry: io_registry_entry_t = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler")
        let _ = IORegistryEntrySetCFProperty(registry, "IORequestIdle", true)
        IOObjectRelease(registry)
    }
    
    func lockScreenImmediate() -> Void {
        // Note: Private -- Do not use!
        // http://stackoverflow.com/questions/34669958/swift-how-to-call-a-c-function-loaded-from-a-dylib
        
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) Void -> Void
        let SACLockScreenImmediate = unsafeBitCast(sym, myFunction.self)
        SACLockScreenImmediate()
    }
    
    @IBAction func statusItemLock(sender: NSMenuItem) {
        screenSleep()
    }

}

