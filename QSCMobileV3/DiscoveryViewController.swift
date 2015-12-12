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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
