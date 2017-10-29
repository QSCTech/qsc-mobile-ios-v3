//
//  DiscoverViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-31.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import WebKit

let DiscoverURL   = URL(string: "https://notice.zjuqsc.com/mobile/")!
let DiscoverColor = UIColor(red: 0.945, green: 0.643, blue: 0.122, alpha: 1.0)

class DiscoverViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: CGRect.zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.load(URLRequest(url: DiscoverURL))
        view.addSubview(webView)
        view.addConstraint(webView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        view.addConstraint(webView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        view.addConstraint(webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor))
        view.addConstraint(webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor))
        view.backgroundColor = DiscoverColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
