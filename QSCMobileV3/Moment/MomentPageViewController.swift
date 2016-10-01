//
//  MomentPageViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-29.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import GaugeKit
import DeviceKit
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
    var momentViewController: MomentViewController!
    
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let event = event {
            dateLabel.hidden = true
            detailButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
            detailButton.layer.cornerRadius = 14
            detailButton.layer.borderWidth = 1
            
            let color = QSCColor.categoría(event.category)
            let startColor: UIColor
            let endColor: UIColor // Waiting for GaugeKit upgrade to make endColor work
            switch event.category {
            case .Course, .Lesson:
                startColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
                endColor = UIColor(red: 0.157, green: 0.533, blue: 0.588, alpha: 1.0)
                promptLabel.text = "距上课"
            case .Exam, .Quiz:
                startColor = UIColor(red: 1.0, green: 0.0, blue: 0.431, alpha: 1.0)
                endColor = UIColor(red: 0.902, green: 0.604, blue: 0.259, alpha: 1.0)
                promptLabel.text = "距考试开始"
            case .Activity:
                startColor = UIColor(red: 1.0, green: 0.855, blue: 0.0, alpha: 1.0)
                endColor = UIColor(red: 0.988, green: 1.0, blue: 0.533, alpha: 1.0)
                promptLabel.text = "距活动开始"
            case .Todo:
                startColor = QSCColor.todo
                endColor = QSCColor.todo
                promptLabel.text = "距日程开始"
            case .Bus:
                startColor = UIColor(red: 0.106, green: 0.616, blue: 0.161, alpha: 1.0)
                endColor = UIColor(red: 0.776, green: 0.918, blue: 0.392, alpha: 1.0)
                promptLabel.text = "距校车出发"
            }
            timerLabel.textColor = color
            gauge.startColor = startColor
            gauge.endColor = endColor
            detailButton.setTitleColor(color, forState: .Normal)
            detailButton.layer.borderColor = color.CGColor
        } else {
            if Device().isPad {
                dateLabel.hidden = true
            }
            promptLabel.text = ""
            gauge.rate = 0
            detailButton.hidden = true
            
            timerLabel.textColor = UIColor.blackColor()
        }
        gauge.bgColor = UIColor.whiteColor()
        gauge.bgAlpha = 0.9
        
        refresh()
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    
    func refresh() {
        if let event = event {
            if NSDate() < event.start {
                gauge.maxValue = CGFloat(event.start.timeIntervalSinceDate(NSDate().today))
                gauge.rate = CGFloat(NSDate().timeIntervalSinceDate(NSDate().today))
                let timer = Int(gauge.maxValue - gauge.rate) + 60
                timerLabel.text = String(format: "%02d:%02d", timer / 3600, timer / 60 % 60)
            } else if NSDate() <= event.end {
                gauge.maxValue = CGFloat(event.end.timeIntervalSinceDate(event.start))
                gauge.rate = CGFloat(NSDate().timeIntervalSinceDate(event.start))
                let timer = Int(gauge.maxValue - gauge.rate) + 60
                timerLabel.text = String(format: "%02d:%02d", timer / 3600, timer / 60 % 60)
                if event.category == .Course || event.category == .Lesson {
                    promptLabel.text = "距下课"
                } else if event.category == .Bus {
                    promptLabel.text = "距校车到达"
                } else {
                    promptLabel.text = promptLabel.text!.stringByReplacingOccurrencesOfString("开始", withString: "结束")
                }
            } else {
                gauge.rate = 0
                promptLabel.text = "日程"
                timerLabel.text = "结束"
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
    
    @IBAction func showDetail(sender: AnyObject) {
        if event!.category == .Course || event!.category == .Exam {
            let storyboard = UIStoryboard(name: "CourseDetail", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateInitialViewController() as! CourseDetailViewController
            vc.managedObject = event!.object
            vc.hidesBottomBarWhenPushed = true
            momentViewController.showViewController(vc, sender: nil)
        } else {
            let storyboard = UIStoryboard(name: "EventDetail", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateInitialViewController() as! EventDetailViewController
            vc.customEvent = event!.object as! CustomEvent
            vc.hidesBottomBarWhenPushed = true
            momentViewController.showViewController(vc, sender: nil)
        }
    }
    
}
