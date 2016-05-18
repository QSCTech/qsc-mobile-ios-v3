//
//  DiscoverViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-05.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit
import Kingfisher
import QSCMobileKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let noticeManager = NoticeManager.sharedInstance
        noticeManager.allEventsWithPage(1) { events, error in
            guard let events = events else {
                self.textView.text = error
                return
            }
            self.textView.text = events.description
            self.imageView.kf_setImageWithURL(events[0].sponsorLogoURL)
            noticeManager.updateDetailWithEvent(events[0]) { event, error in
                guard let event = event else {
                    self.textView.text = error
                    return
                }
                self.textView.text = event.content
            }
        }
    }

}
