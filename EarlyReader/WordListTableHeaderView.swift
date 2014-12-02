//
//  WordListTableHeaderView.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/18/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

protocol WordListTableHeaderViewDelegate {
    func didClickHeaderButton(sender:WordListTableHeaderView, button: UIButton)
}


class WordListTableHeaderView: UIView {

    var delegate : WordListTableHeaderViewDelegate?
    var wordSection : WordListViewController.WordSection = .AvailableWords
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func didClickButton(sender: UIButton) {
        if let d = delegate {
            d.didClickHeaderButton(self, button : sender)
        }
    }
}
