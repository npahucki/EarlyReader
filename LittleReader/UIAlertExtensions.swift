//
//  File.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import UIKit

typealias UIAlertViewClosure = Int -> ()


@objc private class ClosureWrapper {
    
    init(closure : UIAlertViewClosure) {
        self.closure = closure
    }
    
    var closure : UIAlertViewClosure!
}

private let _closurePropKey = malloc(4)

extension UIAlertView : UIAlertViewDelegate {

    
    class func showGenericLocalizedErrorMessage(msg_key: NSString) {
        self.showLocalizedErrorMessageWithOkButton(msg_key, title_key: "error_title_generic")
    }

    class func showGenericLocalizedSuccessMessage(msg_key: NSString) {
        self.showLocalizedErrorMessageWithOkButton(msg_key, title_key: "success_title_generic")
    }
    
    class func showLocalizedErrorMessageWithOkButton(msg_key: NSString, title_key: NSString) {
        let title = NSLocalizedString(title_key, comment:"")
        let msg = NSLocalizedString(msg_key, comment:"")
        let cancelTitle = NSLocalizedString("uialert_accept_button_title", comment:"")
        UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle : cancelTitle).show()
    }
  
    public func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if let blockWrapper = objc_getAssociatedObject(self, _closurePropKey) as? ClosureWrapper {
          blockWrapper.closure(buttonIndex)
        }
    }
    
    func showAlertWithButtonBlock(closure: UIAlertViewClosure) {
        let wrapper = ClosureWrapper(closure)
        objc_setAssociatedObject(self, _closurePropKey, wrapper,UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        self.delegate = self;
        self.show()
    }
}