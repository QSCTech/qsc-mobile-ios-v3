//
//  TodayViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-05.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class TodayViewController: UIViewController {

    let mobileManager: MobileManager = MobileManager.sharedInstance
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.text += ZjuwlanConnection.currentSSID + "\n"
        ZjuwlanConnection.link { status, error in
            if !status {
                print(error!)
            }
            self.mobileManager.refreshAll {
                self.textView.text += self.mobileManager.coursesForDate(NSDate()).description
            }
        }
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
