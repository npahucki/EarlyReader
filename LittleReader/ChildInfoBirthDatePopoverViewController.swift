//
//  ChildInfoBirthDatePopoverViewController.swift
//  LittleReader
//
//  Created by Nathan  Pahucki on 11/15/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

protocol ChildInfoBirthDatePopoverViewControllerDelegate {
    func changedChildBirthDate(date : NSDate)
}

class ChildInfoBirthDatePopoverViewController: UIViewController {


    
    var baby : Baby!
    var delegate : ChildInfoBirthDatePopoverViewControllerDelegate!
    
    @IBOutlet weak var bornOnLabel: UILabel!
    @IBOutlet weak var birthDate: UIDatePicker!
   
    
    override func viewDidLoad() {
        assert(baby != nil, "Expected Baby to be set")
        assert(delegate != nil,"Expected delegate to be set")
        birthDate.maximumDate = NSDate()
        if let bd = baby.birthDate {
            birthDate.date = bd
        }
        bornOnLabel.text = bornOnLabel.text?.stringByReplacingOccurrencesOfString("${name}", withString: baby.name)
    }
    
    @IBAction func datePickerDidChange(sender: UIDatePicker) {
        delegate.changedChildBirthDate(sender.date)
    }
}
