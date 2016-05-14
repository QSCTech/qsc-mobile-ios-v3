//
//  BrowserViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

// TODO: Change UIWebView to WKWebView
class BrowserViewController: UIViewController {
    
    init(request: NSURLRequest) {
        urlRequest = request
        super.init(nibName: "BrowserViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var urlRequest: NSURLRequest!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backwardButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 26)!], forState: .Normal)
        forwardButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 26)!], forState: .Normal)
        navBar.delegate = self
        webView.delegate = self
        webView.loadRequest(urlRequest)
        activityIndicator.startAnimating()
    }

    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backward(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        webView.reload()
    }
    
}

extension BrowserViewController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}

extension BrowserViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.hidden = true
        navItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        backwardButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
    }
    
}
