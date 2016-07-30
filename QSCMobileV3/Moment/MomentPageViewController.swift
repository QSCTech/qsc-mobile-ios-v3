//
//  MomentPageViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import GaugeKit
import QSCMobileKit

class MomentPageViewController: UIViewController {
    
    init(event: Event?) {
        self.event = event
        super.init(nibName: "MomentPageViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var event: Event?
    
    private let mobileManager = MobileManager.sharedInstance
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let event = event {
            titleLabel.text = event.name
            dateLabel.hidden = true
            stackView.hidden = false
            timeLabel.text = event.time
            placeLabel.text = event.place
            
            let color: UIColor
            let startColor: UIColor
            let endColor: UIColor
            switch event.category {
            case .Course, .Lesson:
                color = QSCColor.course
                startColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
                endColor = UIColor(red: 0.157, green: 0.533, blue: 0.588, alpha: 1.0)
                promptLabel.text = "距上课"
            case .Exam, .Quiz:
                color = QSCColor.exam
                startColor = UIColor(red: 1.0, green: 0.0, blue: 0.431, alpha: 1.0)
                endColor = UIColor(red: 0.902, green: 0.604, blue: 0.259, alpha: 1.0)
                promptLabel.text = "距考试开始"
            default:
                color = UIColor(red: 0.722, green: 0.592, blue: 0.0, alpha: 1.0)
                startColor = UIColor(red: 1.0, green: 0.855, blue: 0.0, alpha: 1.0)
                endColor = UIColor(red: 0.988, green: 1.0, blue: 0.533, alpha: 1.0)
                promptLabel.text = "距活动开始"
            }
            titleLabel.textColor = color
            timerLabel.textColor = color
            timeLabel.textColor = color
            placeLabel.textColor = color
            gauge.startColor = startColor
            gauge.endColor = endColor
            gauge.bgColor = UIColor.whiteColor()
        } else {
            titleLabel.text = "今日无事"
            promptLabel.text = ""
            stackView.hidden = true
            gauge.rate = 0
            
            timerLabel.textColor = UIColor.blackColor()
            gauge.bgColor = UIColor.whiteColor()
        }
        
        refresh()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    
    func refresh() {
        if let event = event {
            if NSDate() < event.start {
                let today = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
                gauge.maxValue = CGFloat(event.start.timeIntervalSinceDate(today))
                gauge.rate = CGFloat(NSDate().timeIntervalSinceDate(today))
                let timer = Int(gauge.maxValue - gauge.rate)
                timerLabel.text = String(format: "%d:%02d", timer / 3600, timer / 60 % 60)
            } else if NSDate() <= event.end {
                gauge.maxValue = CGFloat(event.end.timeIntervalSinceDate(event.start))
                gauge.rate = CGFloat(NSDate().timeIntervalSinceDate(event.start))
                let timer = Int(gauge.maxValue - gauge.rate)
                timerLabel.text = String(format: "%d:%02d", timer / 3600, timer / 60 % 60)
                if event.category == .Course {
                    promptLabel.text = "距下课"
                } else {
                    promptLabel.text = promptLabel.text!.stringByReplacingOccurrencesOfString("开始", withString: "结束")
                }
            } else {
                gauge.rate = 0
                timerLabel.text = "已结束"
                promptLabel.text = ""
            }
        } else {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "zh_CN")
            formatter.dateFormat = "HH:mm"
            timerLabel.text = formatter.stringFromDate(NSDate())
            formatter.dateFormat = "MM-dd EEE"
            dateLabel.text = formatter.stringFromDate(NSDate())
        }
    }
    
}
