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
            request = URLRequest(url: URL(string: url)!)
        }
        name = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var request: URLRequest?
    var name: String?
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.white
        view = webView
        
        navigationItem.title = name
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        if let request = request {
            webView.load(request)
        } else {
            let htmlFile = Bundle.main.path(forResource: "Copyright", ofType: "html")!
            let htmlString = try! String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8)
            webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        }
    }

}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.isHidden = true
    }
    
}
