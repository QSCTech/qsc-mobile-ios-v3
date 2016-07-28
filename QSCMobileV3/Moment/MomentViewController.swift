//
//  MomentViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-18.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import GaugeKit
import QSCMobileKit

class MomentViewController: UIViewController {
    
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var nothingLabel: UILabel!
    
    let mobileManager = MobileManager.sharedInstance
    
    var eventsToday = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventsToday = mobileManager.eventsForDate(NSDate())
        refresh()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        eventsToday = mobileManager.eventsForDate(NSDate())
    }
    
    func refresh() {
        let calendar = NSCalendar.currentCalendar()
        if !calendar.isDateInToday(NSDate(timeIntervalSinceNow: -1)) {
            eventsToday = mobileManager.eventsForDate(NSDate())
        }
        
        let events = eventsToday.filter { $0.end >= NSDate() }
        if events.isEmpty {
            navigationItem.title = ""
            pageControl.hidden = true
            gauge.bgColor = UIColor.whiteColor()
            gauge.rate = 0
            promptLabel.text = ""
            stackView.hidden = true
            nothingLabel.hidden = false
            
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "zh_CN")
            formatter.dateFormat = "HH:mm"
            timerLabel.text = formatter.stringFromDate(NSDate())
            formatter.dateFormat = "MM-dd EEE"
            dateLabel.text = formatter.stringFromDate(NSDate())
        } else {
            pageControl.hidden = false
            pageControl.numberOfPages = events.count
            let event = events[pageControl.currentPage]
            navigationItem.title = event.name
            
            let color: UIColor
            let startColor: UIColor
            let endColor: UIColor
            switch event.category {
            case .Course, .Lesson:
                color = QSCColor.course
                startColor = UIColor(red: 0.157, green: 0.533, blue: 0.588, alpha: 1.0)
                endColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
                promptLabel.text = "距上课"
            case .Exam, .Quiz:
                color = QSCColor.exam
                startColor = UIColor(red: 0.902, green: 0.604, blue: 0.259, alpha: 1.0)
                endColor = UIColor(red: 1.0, green: 0.0, blue: 0.431, alpha: 1.0)
                promptLabel.text = "距考试"
            case .Activity:
                color = QSCColor.activity
                // FIXME:
                startColor = UIColor(red: 0.988, green: 1.0, blue: 0.533, alpha: 1.0)
                endColor = UIColor(red: 1.0, green: 0.855, blue: 0.0, alpha: 1.0)
                promptLabel.text = "距活动"
            default:
                color = QSCColor.todo
                // FIXME:
                startColor = UIColor(red: 0.988, green: 1.0, blue: 0.533, alpha: 1.0)
                endColor = UIColor(red: 1.0, green: 0.855, blue: 0.0, alpha: 1.0)
                promptLabel.text = "距日程"
            }
            navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: color]
            timerLabel.textColor = color
            timeLabel.textColor = color
            placeLabel.textColor = color
            gauge.startColor = startColor
            gauge.endColor = endColor
            gauge.bgColor = UIColor.whiteColor()
            
            dateLabel.hidden = true
            stackView.hidden = false
            timeLabel.text = event.time
            placeLabel.text = event.place
            nothingLabel.hidden = true
            
            if NSDate() >= event.start {
                gauge.maxValue = CGFloat(event.end.timeIntervalSinceDate(event.start))
                gauge.rate = CGFloat(NSDate().timeIntervalSinceDate(event.start))
                if event.category == .Course {
                    promptLabel.text = "距下课"
                } else {
                    promptLabel.text! += "结束"
                }
            } else {
                let today = calendar.startOfDayForDate(NSDate())
                gauge.maxValue = CGFloat(event.start.timeIntervalSinceDate(today))
                gauge.rate = CGFloat(NSDate().timeIntervalSinceDate(today))
            }
            let timer = Int(gauge.maxValue - gauge.rate)
            timerLabel.text = String(format: "%d:%02d", timer / 3600, timer / 60 % 60)
        }
    }
    
    @IBAction func pageDidChange(sender: UIPageControl) {
        refresh()
    }
    
}
