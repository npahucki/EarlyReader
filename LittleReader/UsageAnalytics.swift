//
//  UsageAnalytics.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/21/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

@objc(UsageAnalytics)
class UsageAnalytics {
    
    class func trackError(description: NSString, error: NSError) {
        NSLog("ERROR: %@  -  %@", description, error)
    }
    
    
}