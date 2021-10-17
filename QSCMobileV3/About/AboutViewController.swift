//
//  AboutViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-10-31.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation
import QSCMobileKit

class AboutViewController: UIViewController {
    
    init() {
        super.init(nibName: "AboutViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var easterEggView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "关于我们"
        versionLabel.text = QSCVersion
        
        imageView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        imageView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        imageView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        imageView4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        logoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(easterEggHandler)))
        view.backgroundColor = ColorCompatibility.systemBackground
    }
    
    let url = [
        "https://yzsun.me/?qsc",
        "https://iynix.lofter.com",
        "https://www.qsc.zju.edu.cn/",
        "http://alej.wang",
    ]
    
    @objc func tapHandler(_ sender: UITapGestureRecognizer) {
        let svc = SFSafariViewController(url: URL(string: url[sender.view!.tag])!)
        present(svc, animated: true)
    }
    
    var audioPlayer: AVAudioPlayer?
    var easterEggCounter = 0
    @objc func easterEggHandler(_ sender: AnyObject) {
        easterEggCounter += 1
        if easterEggCounter == 5 {
            navigationItem.title = "初日♪"
            easterEggView.isHidden = false
            guard let url = Bundle.main.url(forResource: "EasterEgg", withExtension: "mp3") else { return }
            try? AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = audioPlayer else { return }
            player.play()
            print("Easter Egg!")
        }
    }
    
    @IBAction func showCopyright(_ sender: AnyObject) {
        let vc = WebViewController(url: nil, title: "版权信息")
        show(vc, sender: nil)
    }
    
}
