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

    let accountManager = AccountManager.sharedInstance
    let mobileManager = MobileManager.sharedInstance
    let calendarManager = CalendarManager.sharedInstance
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if accountManager.currentAccountForJwbinfosys == nil {
            mobileManager.loginValidate("freshman", "ios") { status, error in
                if status {
                    self.textView.text = "Login successfully"
                } else {
                    self.textView.text = error
                }
            }
        } else {
            mobileManager.refreshAll {
                let date = NSDate(timeIntervalSinceNow: 0)
                self.textView.text = self.mobileManager.coursesForDate(date).description
                self.textView.text += "\n" + self.calendarManager.adjustmentForDate(date).debugDescription
                self.textView.text += "\n" + self.calendarManager.holidayForDate(date).debugDescription
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
