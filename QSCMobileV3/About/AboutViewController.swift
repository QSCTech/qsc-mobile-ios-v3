//
//  AboutViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-10-31.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SafariServices
import QSCMobileKit

class AboutViewController: UIViewController {
    
    init() {
        super.init(nibName: "AboutViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "关于我们"
        versionLabel.text = "Version " + QSCVersion
        
        imageView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        imageView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        imageView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
    }
    
    let url = [
        "http://yzyzsun.me",
        "http://alej.wang",
        "http://iynix.lofter.com",
    ]
    
    func tapHandler(sender: UITapGestureRecognizer) {
        print("tapped")
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: url[sender.view!.tag])!)
            presentViewController(svc, animated: true, completion: nil)
        }
    }
    
    @IBAction func showCopyright(sender: AnyObject) {
        let vc = WebViewController(url: nil, title: "版权信息")
        showViewController(vc, sender: nil)
    }
    
}
