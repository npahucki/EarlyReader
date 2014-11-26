//
//  NSErrorExtensions.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/17/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation

extension NSError {
    
    enum ErrorCode : Int {
        case FailedToImportWords = 1000
        case FailedToImportEntites = 1010
    }
    
    class func applicationError(code: ErrorCode, description : String? = nil, failureReason : String? = nil, cause:NSError? = nil) -> NSError {
        let domain = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey] as String
        let dict = NSMutableDictionary()
        if let d = description { dict[NSLocalizedDescriptionKey] = d }
        if let f = failureReason { dict[NSLocalizedFailureReasonErrorKey] = f }
        if let e = cause { dict[NSUnderlyingErrorKey] = e }
        return NSError(domain: domain, code: code.rawValue, userInfo: dict)
    }
}



