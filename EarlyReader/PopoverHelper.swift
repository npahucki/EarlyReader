//
//  ToolTipTextBubble.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 12/11/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//



import UIKit


/// Provide popups that text can be shown in for tips and information
class PopoverHelper : NSObject, UIPopoverControllerDelegate {
    
    
    var pinToView : UIView?
    var maxWidth = UIScreen.mainScreen().bounds.width / 3 * 2
    var maxHeight = UIScreen.mainScreen().bounds.width / 3 * 2
    var permittedArrowDirections = UIPopoverArrowDirection.Any
    private var _infoPopover : UIPopoverController?
    private var _callBack: (() -> ())?
    
    
    func showToolTipBubble(textToShow : String, callBack : () -> ()) {
        assert(pinToView != nil)
        _callBack = callBack
        
        var popoverContentView = UIView()
        popoverContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        var label = UILabel()
        label.font = UIFont(name: "OpenSans-Light", size : 17.0)
        label.textColor = UIColor.applicationTextColor()
        label.numberOfLines = 0
        label.text = textToShow
        let padding = CGFloat(16)
        let labelSize = label.sizeThatFits(CGSize(width: CGFloat(maxWidth) - padding, height: CGFloat(maxHeight) - padding))
        let size = CGSize(width: labelSize.width + padding, height: labelSize.height + padding)
        popoverContentView.addSubview(label)
        label.center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        label.bounds = CGRect(x:0,y:0,width:labelSize.width, height: labelSize.height)
        
        let popoverContentViewController = UIViewController()
        popoverContentViewController.view = popoverContentView
        popoverContentViewController.preferredContentSize = size
        _infoPopover = UIPopoverController(contentViewController: popoverContentViewController)
        _infoPopover!.popoverContentSize = size
        _infoPopover!.delegate = self
        _infoPopover!.presentPopoverFromRect(pinToView!.frame, inView: pinToView!.superview!, permittedArrowDirections: permittedArrowDirections, animated: true)
        
    }

    func showPopUpWithController(vc : UIViewController, callBack : () -> ()) {
        assert(pinToView != nil)
        _callBack = callBack
        _infoPopover = UIPopoverController(contentViewController: vc)
        _infoPopover!.popoverContentSize = vc.preferredContentSize
        _infoPopover!.delegate = self
        _infoPopover!.presentPopoverFromRect(pinToView!.frame, inView: pinToView!.superview!, permittedArrowDirections: permittedArrowDirections, animated: true)
        
    }
    
    func dismiss() {
        if let p = _infoPopover {
            p.dismissPopoverAnimated(true)
            popoverControllerDidDismissPopover(p)
            _infoPopover = nil
        }
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        _infoPopover = nil // let it go
        if let callBack = _callBack {
            callBack()
        }
    }

}


