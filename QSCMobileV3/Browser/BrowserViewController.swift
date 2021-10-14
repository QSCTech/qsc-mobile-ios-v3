//
//  BrowserViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//
import UIKit
import QSCMobileKit
import Alamofire
import SwiftyJSON
// TODO: Change UIWebView to WKWebView
class BrowserViewController: UIViewController {
    
    init(request: URLRequest) {
        urlRequest = request
        super.init(nibName: "BrowserViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    enum Website: String {
        case jwbinfosys = "http://jwbinfosys.zju.edu.cn/xsmain_pyjh.htm"
        case mail      = "http://mail.zju.edu.cn/coremail/login.jsp"
        case myvpn      = "http://myvpn.zju.edu.cn/j_security_check"
        case passCode   = "https://passcode.zju.edu.cn/pass_code/zx"
    }
    
    static func builtin(website: Website) -> BrowserViewController {
        
        let accountManager = AccountManager.sharedInstance
        let loginMethod = accountManager.methodForUsername
        // TODO: Handle login errors
        let url = URL(string: website.rawValue)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        switch website {
        case .jwbinfosys:
            request.httpMethod = "GET"
            let username = accountManager.currentAccountForJwbinfosys!.percentEncoded
            let password = accountManager.passwordForJwbinfosys(username)!.percentEncoded
            DispatchQueue.global().async {
                if let props = getCookie(username: username, password: password, method: loginMethod[username]=="jwb" ? LoginMethod.Jwb : LoginMethod.ZJU_passport) {
                    let cookie = HTTPCookie(properties: props)
                    let cstorage = HTTPCookieStorage.shared
                    cstorage.setCookie(cookie!)
                }
            }
        case .mail:
            let username = accountManager.accountForZjuwlan!.percentEncoded
            let password = accountManager.passwordForZjuwlan!.percentEncoded
            request.httpBody = "service=PHONE&face=XJS&locale=zh_CN&destURL=%2Fcoremail%2Fxphone%2Fmain.jsp&uid=\(username)&password=\(password)&action%3Alogin=".data(using: String.Encoding.ascii)
        case .myvpn:
            let username = accountManager.accountForZjuwlan!.percentEncoded
            let password = accountManager.passwordForZjuwlan!.percentEncoded
            request.httpBody = "j_username=\(username)&j_password=\(password)".data(using: String.Encoding.ascii)
        case .passCode: break
        }
        return BrowserViewController(request: request)
    }
    
    var urlRequest: URLRequest!
    var webViewDidFinishLoadCallback: ((UIWebView) -> Void)?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var backwardButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.delegate = self
        webView.delegate = self
        webView.loadRequest(urlRequest)
        activityIndicator.startAnimating()
        view.backgroundColor = ColorCompatibility.systemBackground
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
        webViewDidFinishLoadCallback?(webView)
        if urlRequest.url!.absoluteString == Website.passCode.rawValue {
            let username = AccountManager.sharedInstance.currentAccountForJwbinfosys!.percentEncoded
            let password = AccountManager.sharedInstance.passwordForJwbinfosys(username)!.percentEncoded
            let simClick = "document.querySelector('#username').value = 'un' \ndocument.querySelector('#password').value = 'pd'\ndocument.querySelector('#dl').click()".replacingOccurrences(of: "un", with: username).replacingOccurrences(of: "pd", with: password)
            
            webView.stringByEvaluatingJavaScript(from: simClick)
    
        }
    }
    
}
