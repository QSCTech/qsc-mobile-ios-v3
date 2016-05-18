//
//  MomentViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class MomentViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        timeLabel.text = ""
        dateLabel.text = ""
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }
    
    func timerTick() {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "zh_CN")
        formatter.dateFormat = "HH:mm:ss"
        timeLabel.text = formatter.stringFromDate(NSDate())
        formatter.dateFormat = "MM-dd EEE"
        dateLabel.text = formatter.stringFromDate(NSDate())
    }
    
}
