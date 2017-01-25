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
    
    init(request: URLRequest) {
        urlRequest = request
        super.init(nibName: "BrowserViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var urlRequest: URLRequest!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backwardButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 26)!], for: .normal)
        forwardButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 26)!], for: .normal)
        navBar.delegate = self
        webView.delegate = self
        webView.loadRequest(urlRequest)
        activityIndicator.startAnimating()
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    @IBAction func backward(_ sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func forward(_ sender: AnyObject) {
        webView.goForward()
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        webView.reload()
    }
    
}

extension BrowserViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension BrowserViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = true
        navItem.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        backwardButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
}
