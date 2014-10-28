//
//  Common.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/24/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import CoreData



let WORDS_PER_WORDSET = 5
let WORD_VIEWS_BEFORE_RETIREMENT : UInt16 = 15
let TIME_INTERVAL_24_HOURS = NSTimeInterval(60 * 60 * 24)


// Icky Global, but no other good way to get the context to Baby class.
var _mainManagedObjectContext : NSManagedObjectContext? = nil


//enum Result<T> {
//    case Success(T)
//    case Failure(String)
//
//    func map<P>(f: T -> P) -> Result<P> {
//        switch self {
//        case Success(let value):
//            return .Success(f(value))
//        case Failure(let errString):
//            return .Failure(errString)
//        }
//    }
//}
//

