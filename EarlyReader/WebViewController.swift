//
//  WebViewController.swift
//  EarlyReader
//
//  Created by Nathan  Pahucki on 11/28/14.
//  Copyright (c) 2014 Nathan Pahucki. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    private var _url : String?
    
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
        webView.delegate = self
        if let url = _url {
            if let nsUrl = NSURL(string: url) {
                webView.loadRequest(NSURLRequest(URL: nsUrl))
            }
        }
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
    
    
    
}
