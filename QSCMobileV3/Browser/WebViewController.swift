//
//  WebViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-11.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import WebKit
import QSCMobileKit

class WebViewController: UIViewController {
    
    init(url: String?, title: String?) {
        if let url = url {
            request = NSURLRequest(URL: NSURL(string: url)!)
        }
        name = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var request: NSURLRequest?
    var name: String?
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.whiteColor()
        view = webView
        
        navigationItem.title = name
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        if let request = request {
            webView.loadRequest(request)
        } else {
            let htmlFile = NSBundle.mainBundle().pathForResource("Copyright", ofType: "html")!
            let htmlString = try! String(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
            webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
        }
    }

}

extension WebViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.hidden = false
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        activityIndicator.hidden = true
    }
    
}
