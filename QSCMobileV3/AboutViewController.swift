//
//  AboutViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-05.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class AboutViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let htmlFile = NSBundle.mainBundle().pathForResource("About", ofType: "html"), htmlString = try? String(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding) {
            let htmlString = htmlString.stringByReplacingOccurrencesOfString("<%= version %>", withString: "\(QSCVersion)")
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }

}
