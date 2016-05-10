//
//  DiscoveryViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-05.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class DiscoveryViewController: UIViewController {

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
            noticeManager.updateSpnsorImageWithEvent(events[0]) { event in
                self.imageView.image = event.sponsorLogo
            }
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
