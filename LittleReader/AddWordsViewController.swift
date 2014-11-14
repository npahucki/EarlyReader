//
//  AddWordsViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 10/28/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class AddWordsViewController: UIViewController {

    var settingsViewController : SettingsListViewController? = nil
    
    @IBOutlet weak var textView: UITextView!
    @IBAction func didClickDoneButton(sender: UIButton) {
        // TODO: Much better parsing!
        if(!self.textView.text.isEmpty) {
            let words = self.textView.text.componentsSeparatedByString("\n") as [String]
            if let vc = self.settingsViewController {
                vc.insertWords(words)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.textView.layer.borderWidth = 1
    }
}
