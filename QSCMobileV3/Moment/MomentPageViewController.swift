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
        super.init(nibName: "MomentPageViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var event: Event?
    
    let mobileManager = MobileManager.sharedInstance
    var momentViewController: MomentViewController!
    
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let event = event {
            dateLabel.isHidden = true
            detailButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
            detailButton.layer.cornerRadius = 14
            detailButton.layer.borderWidth = 1
            
            let color = QSCColor.categoría(event.category)
            let startColor: UIColor
            let endColor: UIColor // Waiting for GaugeKit upgrade to make endColor work
            switch event.category {
            case .course, .lesson:
                startColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
                endColor = UIColor(red: 0.157, green: 0.533, blue: 0.588, alpha: 1.0)
                promptLabel.text = "距上课"
            case .exam, .quiz:
                startColor = UIColor(red: 1.0, green: 0.0, blue: 0.431, alpha: 1.0)
                endColor = UIColor(red: 0.902, green: 0.604, blue: 0.259, alpha: 1.0)
                promptLabel.text = "距考试开始"
            case .activity:
                startColor = UIColor(red: 1.0, green: 0.855, blue: 0.0, alpha: 1.0)
                endColor = UIColor(red: 0.988, green: 1.0, blue: 0.533, alpha: 1.0)
                promptLabel.text = "距活动开始"
            case .todo:
                startColor = QSCColor.todo
                endColor = QSCColor.todo
                promptLabel.text = "距日程开始"
            case .bus:
                startColor = UIColor(red: 0.106, green: 0.616, blue: 0.161, alpha: 1.0)
                endColor = UIColor(red: 0.776, green: 0.918, blue: 0.392, alpha: 1.0)
                promptLabel.text = "距校车出发"
            }
            timerLabel.textColor = color
            gauge.startColor = startColor
            gauge.endColor = endColor
            detailButton.setTitleColor(color, for: .normal)
            detailButton.layer.borderColor = color.cgColor
        } else {
            if Device().isPad {
                dateLabel.isHidden = true
            }
            promptLabel.text = ""
            gauge.rate = 0
            detailButton.isHidden = true
            
            timerLabel.textColor = UIColor.black
        }
        gauge.bgColor = UIColor.white
        gauge.bgAlpha = 0.9
        
        refresh()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    
    @objc func refresh() {
        if let event = event {
            if Date().tomorrow <= event.start {
                let days = Int(event.start.today.timeIntervalSince(Date().today) / 86400)
                gauge.maxValue = 30
                gauge.rate = CGFloat(30 - days)
                timerLabel.text = "\(days)日"
            } else if Date() < event.start {
                gauge.maxValue = CGFloat(event.start.timeIntervalSince(Date().today))
                gauge.rate = CGFloat(Date().timeIntervalSince(Date().today))
                timerLabel.text = event.start.timeIntervalSince(Date()).timeDescription
            } else if Date() <= event.end {
                gauge.maxValue = CGFloat(event.end.timeIntervalSince(event.start))
                gauge.rate = CGFloat(Date().timeIntervalSince(event.start))
                timerLabel.text = event.end.timeIntervalSince(Date()).timeDescription
                if event.category == .course || event.category == .lesson {
                    promptLabel.text = "距下课"
                } else if event.category == .bus {
                    promptLabel.text = "距校车到达"
                } else {
                    promptLabel.text = promptLabel.text!.replacingOccurrences(of: "开始", with: "结束")
                }
            } else {
                gauge.rate = 0
                promptLabel.text = "日程"
                timerLabel.text = "结束"
            }
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "HH:mm"
            timerLabel.text = formatter.string(from: Date())
            formatter.dateFormat = "MM-dd EEE"
            dateLabel.text = formatter.string(from: Date())
        }
    }
    
    @IBAction func showDetail(_ sender: AnyObject) {
        if event!.category == .course || event!.category == .exam {
            let storyboard = UIStoryboard(name: "CourseDetail", bundle: Bundle.main)
            let vc = storyboard.instantiateInitialViewController() as! CourseDetailViewController
            vc.managedObject = event!.object
            vc.hidesBottomBarWhenPushed = true
            momentViewController.show(vc, sender: nil)
        } else {
            let storyboard = UIStoryboard(name: "EventDetail", bundle: Bundle.main)
            let vc = storyboard.instantiateInitialViewController() as! EventDetailViewController
            vc.customEvent = event!.object as! CustomEvent
            vc.hidesBottomBarWhenPushed = true
            momentViewController.show(vc, sender: nil)
        }
    }
    
}
