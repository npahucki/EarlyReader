//
//  NSUserDefaultsExtensions.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

extension NSUserDefaults {
    
    // Return true if the key was not set yet, and then sets the key such that 
    // subsequent calls will always return false for the same key.
    class func checkFlagNotSetWithKey(key : String) -> Bool {
        let defs = self.standardUserDefaults()
        if !defs.boolForKey(key) {
            defs.setBool(true, forKey: key)
            return true
        }
        return false
    }
}
