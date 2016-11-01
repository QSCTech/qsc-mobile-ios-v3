//
//  DiscoverViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-31.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import WebKit

let DiscoverURL = "https://notice.zjuqsc.com/ios/"

class DiscoverViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 49))
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.loadRequest(NSURLRequest(URL: NSURL(string: DiscoverURL)!))
        view.addSubview(webView)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
