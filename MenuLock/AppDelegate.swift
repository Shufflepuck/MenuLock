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
        let keyMask: NSEventModifierFlags = .CommandKeyMask
        let keyCode = UInt(0x25)
        
        let shortcut = MASShortcut(keyCode: keyCode, modifierFlags: keyMask.rawValue)
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: lockComputer)
    }
    
    @IBAction func statusItemQuit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func lockComputer() {
        let registry: io_registry_entry_t = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler")
        let _ = IORegistryEntrySetCFProperty(registry, "IORequestIdle", true)
        IOObjectRelease(registry)
    }
    
    @IBAction func statusItemLock(sender: NSMenuItem) {
        lockComputer()
    }

}

