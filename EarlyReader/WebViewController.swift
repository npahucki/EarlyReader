//
//  WebViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/28/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

@objc
class WebViewController: UIViewController, UIWebViewDelegate {

    private var _url : String?
    private var _pendingExternalUrl : NSURL?
    private var _parentalGateUnlocked : Bool = false
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var url : String? {
        get {
            return _url
        }
        set(newUrl) {
             _url = newUrl
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleValidationStateChangedNotification:", name: "HTKParentalGateValidationStateChangedNotification", object: nil)
        webView.delegate = self
        if let url = _url {
            if let nsUrl = NSURL(string: url) {
                webView.loadRequest(NSURLRequest(URL: nsUrl))
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        activityIndicator.stopAnimating()
        UIAlertView.showGenericLocalizedErrorMessage("web_view_load_failed")
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            if let currentUrlString = request.URL.absoluteString {
                if !currentUrlString.hasPrefix(_url ?? "") {
                    openExternalUrl(request.URL)
                    return false
                }
            }
        }
        return true
    }

    func openExternalUrl(externalUrl : NSURL) {
        if _parentalGateUnlocked {
            UIApplication.sharedApplication().openURL(externalUrl)
        } else {
            _pendingExternalUrl = externalUrl
            let gateController = HTKParentalGateViewController()
            gateController.showInParentViewController(self, fullScreen: false)
        }
    }
    
    
    func handleValidationStateChangedNotification(notification : NSNotification ) {
       assert(NSThread.isMainThread())
        let state = notification.userInfo!["HTKParentalGateValidationStateChangedKey"]! as NSNumber
        if state.integerValue  == Int(HTKParentalGateValidationState.IsValidated.rawValue) {
            if let url = _pendingExternalUrl {
                _parentalGateUnlocked = true
                openExternalUrl(url)
            }
        } else {
            // TODO: Message
            //            case HTKParentalGateValidationStateInvalid:
            //            case HTKParentalGateValidationStateTimesUp:
            //            case HTKParentalGateValidationStateTooManyAttempts:
            //            case HTKParentalGateValidationStateTooManyIncorrectAnswers:
        }
    }
}
