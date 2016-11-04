//
//  KeyMapClass.swift
//  MenuLock
//
//  Created by keyboard on 13/07/2016.
//  Copyright © 2016 François Levaux. All rights reserved.
//

import Cocoa

class Key: NSObject, NSCoding {
    let name: String
    let keyCode: UInt
    let keyMask: NSEventModifierFlags
    let keyEquivalent: String
    
    init(name: String, keyCode: UInt, keyMask: NSEventModifierFlags, keyEquivalent: AnyObject) {
        self.name = name
        self.keyCode = keyCode
        self.keyMask = keyMask
        if let keyString = keyEquivalent as? String {
            self.keyEquivalent = keyString
        } else if let keyInt = keyEquivalent as? Int {
            self.keyEquivalent = String(utf16CodeUnits: [unichar(keyInt)], count: 1)
        } else {
            abort()
        }
       
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "keyName") as? String,
            let keyCode = aDecoder.decodeObject(forKey: "keyCode") as? UInt,
            let keyMask = aDecoder.decodeObject(forKey: "keyMask") as? UInt,
            let keyEquivalent = aDecoder.decodeObject(forKey: "keyEquivalent") as? String
            else { return nil }
        
        let keyMaskFlags = NSEventModifierFlags(rawValue: keyMask)
        self.init(name: name, keyCode: keyCode, keyMask: keyMaskFlags, keyEquivalent: keyEquivalent as AnyObject)

    }

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "keyName")
        aCoder.encode(self.keyCode, forKey: "keyCode")
        aCoder.encode(self.keyMask.rawValue, forKey: "keyMask")
        aCoder.encode(self.keyEquivalent, forKey: "keyEquivalent")
    }
}
