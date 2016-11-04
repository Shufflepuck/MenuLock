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

    @IBOutlet weak var statusBar: NSMenu!
    @IBOutlet weak var statusLockScreen: NSMenuItem!

    @IBOutlet weak var activeKeyMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var activeKey: Key = Key(name: "CMD + L", keyCode: 0x25, keyMask: [ .command ], keyEquivalent: "l" as AnyObject)
    
    
    // List of available Keys
    
    var keyMaps = [
    Key(name: "F19", keyCode: 80, keyMask: [], keyEquivalent: NSF19FunctionKey as AnyObject),
    Key(name: "CMD + F12", keyCode: 0x6F, keyMask: [ .command ], keyEquivalent: NSF12FunctionKey as AnyObject),
    Key(name: "CMD + L", keyCode: 0x25, keyMask: [ .command ], keyEquivalent: "l" as AnyObject),
    Key(name: "CMD + K", keyCode: 0x28, keyMask: [ .command ], keyEquivalent: "k" as AnyObject)
    ]
    
    @IBAction func statusItemQuit(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func statusItemLock(sender: NSMenuItem) {
        screenSleep()
    }


    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // Setup icon
        
        let icon = NSImage(named: NSImageNameLockLockedTemplate)
        statusItem.image = icon
        statusItem.menu = statusBar
        
        
        // Defaults
        
        setGlobalShortcut()
        
        
        // Setup Active Key Menu
        
        for key in keyMaps {
            let menuItem = NSMenuItem()
            menuItem.title = key.name
            if activeKey.name == key.name {
                menuItem.state = NSOnState
            }
            menuItem.representedObject = key
            menuItem.action = #selector(setActiveKey(sender:))
            activeKeyMenu.addItem(menuItem)
        }
        
    }
    
    
    func setGlobalShortcut() {
        
        if let key: Key = readPrefs() {
            activeKey = key
        } else {
            NSLog("Cannot get activeKey from UserDefaults. Setting current key.")
            savePrefs(key: activeKey)
        }
        
        // Set Menu Item Key Equivalent
        statusLockScreen.keyEquivalent = activeKey.keyEquivalent
        statusLockScreen.keyEquivalentModifierMask = activeKey.keyMask
        
        // Setup Global Shortcut
        let shortcut = MASShortcut(keyCode: activeKey.keyCode, modifierFlags: activeKey.keyMask.rawValue)
        MASShortcutMonitor.shared().register(shortcut, withAction: screenSleep)
        

    }
    
    
    // Set which key should trigger the sleep
    
    func setActiveKey(sender: NSMenuItem) {
        
        for menuItem in activeKeyMenu.items {
            menuItem.state = NSOffState
        }
        sender.state = NSOnState
        if let key: Key = (sender.representedObject as? Key) {
            savePrefs(key: key)
            
            //activeKey = key
        } else {
            NSLog("cannot see representedObject")
        }
        setGlobalShortcut()
    }
    

    

    
    
    
    // Sleep Screen methods
    
    func screenSleep() -> Void {
        let registry: io_registry_entry_t = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler")
        let _ = IORegistryEntrySetCFProperty(registry, "IORequestIdle" as CFString!, true as CFTypeRef!)
        IOObjectRelease(registry)
    }
    
    func lockScreenImmediate() -> Void {
        // Note: Private -- Do not use!
        // http://stackoverflow.com/questions/34669958/swift-how-to-call-a-c-function-loaded-from-a-dylib
        
        let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
        let sym = dlsym(libHandle, "SACLockScreenImmediate")
        typealias myFunction = @convention(c) (Void) -> Void
        let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
        SACLockScreenImmediate()
    }
    
    
    
    // Preferences 
    
    func savePrefs(key: Key) {
        let prefs = UserDefaults()
        let data = NSKeyedArchiver.archivedData(withRootObject: key)
        prefs.set(data, forKey: "currentKey")
        prefs.synchronize()
    }
    
    func readPrefs() -> Key? {
        let prefs = UserDefaults()
        if let object = prefs.object(forKey: "currentKey") {
            if let data = object as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? Key
            } else {
                NSLog("cannot convert to Data")
                return nil
            }
        } else {
            return nil
        }
    }

}

