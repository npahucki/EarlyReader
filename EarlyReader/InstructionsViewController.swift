//
//  InstructionsViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/4/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet weak var testView: UITextView!
    @IBOutlet weak var fadeView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let l = CAGradientLayer()
        l.frame = fadeView.bounds;
        l.colors = [UIColor.whiteColor().CGColor,UIColor.clearColor().CGColor];
        l.startPoint = CGPoint(x: 0.5, y: 0.90)
        l.endPoint = CGPoint(x: 0.5, y: 1.0)
        fadeView.layer.mask = l
    }
    
    
}
