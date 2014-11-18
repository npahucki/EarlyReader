//
//  File.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/23/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertView {

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
}