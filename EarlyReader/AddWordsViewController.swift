//
//  AddWordsViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 10/28/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class AddWordsViewController: UIViewController {

    var wordListController : WordListViewController!
    
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBAction func didClickDoneButton(sender: UIButton) {
        self.view.endEditing(true)
        dismissViewControllerAnimated(true) { () -> Void in
            self.wordListController.didManuallyAddWordsInString(self.textView.text)
        }
    }
    
    override func viewDidLoad() {
        assert(wordListController != nil ,"Expected wordListController to be set before viewDidLoad")
        textView.layer.borderWidth = 1
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowKeyBoard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didHideKeyBoard:", name: UIKeyboardDidHideNotification, object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        // Show keyboard right away.
        textView.becomeFirstResponder()
    }
    
    func didHideKeyBoard(notification: NSNotification) {
        view.layoutIfNeeded()
        textViewBottomConstraint.constant = 8
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func didShowKeyBoard(notification: NSNotification) {
        if let keyboardInfo = notification.userInfo {
            let keyboardFrameBegin = keyboardInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue
            let keyboardFrameBeginRect = view.convertRect(keyboardFrameBegin.CGRectValue(), fromView: nil)
            view.layoutIfNeeded()
            textViewBottomConstraint.constant = keyboardFrameBeginRect.height + 8
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

}
