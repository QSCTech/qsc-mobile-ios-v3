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
    
    override func loadView() {
        webView = WKWebView()
        webView.backgroundColor = UIColor.whiteColor()
        view = webView
        if let request = request {
            webView.loadRequest(request)
        } else {
            let htmlFile = NSBundle.mainBundle().pathForResource("About", ofType: "html")!
            let htmlString = try! String(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding).stringByReplacingOccurrencesOfString("<%= version %>", withString: "\(QSCVersion)")
            webView.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().bundleURL)
        }
        self.navigationItem.title = name
    }

}
