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
    private var _pendingUrlRequest : NSURLRequest?
    private var _parentalGateUnlocked : Bool = false
    private var _gateController =  HTKParentalGateViewController()

    
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
        
        var requiresParentalGate = false;
        switch(navigationType) {
        case .LinkClicked:
            if let currentUrlString = request.URL.absoluteString {
                if !currentUrlString.hasPrefix(_url ?? "") {
                    requiresParentalGate = true
                }
            }
        case .FormSubmitted, .FormResubmitted:
            requiresParentalGate = true
        default:
            requiresParentalGate = false
        }
        
        if requiresParentalGate && !_parentalGateUnlocked {
            _pendingUrlRequest = request
            _gateController.showInParentViewController(self, fullScreen: true)
            return false
        }

        return true
    }
    
    func handleValidationStateChangedNotification(notification : NSNotification ) {
       assert(NSThread.isMainThread())
        let state = notification.userInfo!["HTKParentalGateValidationStateChangedKey"]! as NSNumber
        if state.integerValue  == Int(HTKParentalGateValidationState.IsValidated.rawValue) {
            _parentalGateUnlocked = true
            if let request = _pendingUrlRequest {
                _pendingUrlRequest = nil
                if request.HTTPMethod == "GET" {
                    UIApplication.sharedApplication().openURL(request.URL)
                } else {
                    self.webView.loadRequest(request)
                }
            }
        } else {
            // TODO: Message
            //            case HTKParentalGateValidationStateInvalid:
            //            case HTKParentalGateValidationStateTimesUp:
            //            case HTKParentalGateValidationStateTooManyAttempts:
            //            case HTKParentalGateValidationStateTooManyIncorrectAnswers:
            
            
            // Required to reload, or WebView will not allow submission of forms again!
            self.webView.reload()
        }
    }
}
