//
//  BrowserViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import WebKit

// TODO: Toolbar actions not implemented
// FIXME: Web view position & POST does not work
class BrowserViewController: UIViewController {
    
    init(request: NSURLRequest) {
        urlRequest = request
        super.init(nibName: "BrowserViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var urlRequest: NSURLRequest!
    
    var webView: WKWebView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        view.sendSubviewToBack(webView)
        
        navigationBar.delegate = self
        backwardButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 26)!], forState: .Normal)
        forwardButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 26)!], forState: .Normal)
        webView.loadRequest(urlRequest)
    }

    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerWithAnimation()
    }

}

extension BrowserViewController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}

extension BrowserViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { result, error in
            self.navigationItem.title = result as? String
        }
    }
    
}
