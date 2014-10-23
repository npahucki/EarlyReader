//
//  UIViewControllerWithNSMangedObjectContext.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc protocol ManagedObjectContextHolder {

    var managedContext : NSManagedObjectContext? { get set }

}
