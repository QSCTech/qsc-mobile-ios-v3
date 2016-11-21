//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by kingcyk on 2016/11/1.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import NotificationCenter
import KeychainAccess
import QSCMobileKit

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tskList: UITableView!
    @IBOutlet var firstEventName: UILabel!
    @IBOutlet var firstEventPlace: UILabel!
    @IBOutlet var firstEventTime: UILabel!
    @IBOutlet var firstEventTimeType: UILabel!
    @IBOutlet var firstEventTimeRemain: UILabel!
    @IBOutlet var nothingToDo: UILabel!
    @IBOutlet var line: UIView!
    @IBOutlet var placeIcon: UILabel!
    @IBOutlet var timeIcon: UILabel!
    @IBOutlet var wlanSwitch: UIButton!
    
    let events = eventsForDate(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10, *) { // Only in iOS 10
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        self.preferredContentSize.height = 110
        firstEventTimeRemain.text = nil
        let firstEvents = events.filter { $0.duration == .partialTime && $0.end >= Date() }
        if firstEvents.isEmpty {
            // 今日无事
            nothingToDo.isHidden = false
            line.isHidden = true
            firstEventName.isHidden = true
            firstEventTime.isHidden = true
            firstEventPlace.isHidden = true
            firstEventTimeType.isHidden = true
            firstEventTimeRemain.isHidden = true
            placeIcon.isHidden = true
            timeIcon.isHidden = true
        } else {
            let firstEvent = firstEvents[0]
            firstEventName.text = firstEvent.name
            firstEventPlace.text = firstEvent.place
            firstEventTime.text = firstEvent.time
            let Now = Date()
            let hourNow = Now.stringOfTime.components(separatedBy: ":").first!
            let minuteNow = Now.stringOfTime.components(separatedBy: ":").last!
            let hourStart = firstEvent.start.stringOfTime.components(separatedBy: ":").first!
            let minuteStart = firstEvent.start.stringOfTime.components(separatedBy: ":").last!
            let hourEnd = firstEvent.end.stringOfTime.components(separatedBy: ":").first!
            let minuteEnd = firstEvent.end.stringOfTime.components(separatedBy: ":").last!
            let timeStart = Int(hourStart)! * 60 + Int(minuteStart)!
            let timeEnd = Int(hourEnd)! * 60 + Int(minuteEnd)!
            let timeNow = Int(hourNow)! * 60 + Int(minuteNow)!
            if timeNow >= timeStart {
                firstEventTimeType.text = "距结束还有"
                let remainTimeEnd = timeEnd - timeNow
                let tempString = "\(remainTimeEnd / 60)时 \(remainTimeEnd % 60)分"
                let tempAttributedString = NSMutableAttributedString(string: tempString)
                let fisrtLength = tempString.components(separatedBy: " ").first!.characters.count
                let stringLength = tempString.characters.count
                tempAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 10.0), range: NSRange.init(location: fisrtLength - 1, length: 2))
                tempAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 10.0), range: NSRange.init(location: stringLength - 1, length: 1))
                firstEventTimeRemain.attributedText = tempAttributedString
            } else {
                firstEventTimeType.text = "距开始还有"
                let remainTimeStart = timeStart - timeNow
                let tempString = "\(remainTimeStart / 60)时 \(remainTimeStart % 60)分"
                let tempAttributedString = NSMutableAttributedString(string: tempString)
                let fisrtLength = tempString.components(separatedBy: " ").first!.characters.count
                let stringLength = tempString.characters.count
                tempAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 10.0), range: NSRange.init(location: fisrtLength - 1, length: 2))
                tempAttributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 10.0), range: NSRange.init(location: stringLength - 1, length: 1))
                firstEventTimeRemain.attributedText = tempAttributedString
            }
        }
        
        
        tskList.register(UINib(nibName: "TableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Event")
        tskList.rowHeight = 54
        // self.preferredContentSize.height = CGFloat(self.events.count) * tskList.rowHeight
        // tskList.reloadData()
        // Do any additional setup after loading the view from its nib.
    }
    
    @IBAction func connectWlan() {
        ZjuwlanConnection.link { success, error in
            if success {
                self.wlanSwitch.setTitleColor(UIColor.blue, for: .normal)
            } else {
                self.wlanSwitch.setTitleColor(UIColor.red, for: .normal)
                delay(1, block: {
                    self.wlanSwitch.setTitleColor(UIColor.darkGray, for: .normal)
                })
                self.wlanSwitch.setTitleColor(UIColor.darkGray, for: .normal)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = events[indexPath.row]
        // let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Event")
        // Temporary
        let cell = tskList.dequeueReusableCell(withIdentifier: "Event") as! TableViewCell
        cell.startTime.text = event.start.stringOfTime
        cell.endTime.text = event.end.stringOfTime
        cell.eventName.text = event.name
        cell.eventPlace.text = event.place
        
        let Now = Date()
        
        if event.duration == .partialTime {
            if event.end < Now {
                cell.eventTime.text = "已结束"
            } else {
                let hourNow = Now.stringOfTime.components(separatedBy: ":").first!
                let minuteNow = Now.stringOfTime.components(separatedBy: ":").last!
                let hourStart = event.start.stringOfTime.components(separatedBy: ":").first!
                let minuteStart = event.start.stringOfTime.components(separatedBy: ":").last!
                let hourEnd = event.end.stringOfTime.components(separatedBy: ":").first!
                let minuteEnd = event.end.stringOfTime.components(separatedBy: ":").last!
                let timeStart = Int(hourStart)! * 60 + Int(minuteStart)!
                let timeEnd = Int(hourEnd)! * 60 + Int(minuteEnd)!
                let timeNow = Int(hourNow)! * 60 + Int(minuteNow)!
                if event.start < Now {
                    let remainTimeEnd = timeEnd - timeNow
                    cell.eventTime.text = "距结束 \(remainTimeEnd / 60) 时 \(remainTimeEnd % 60) 分"
                } else {
                    let remainTimeStart = timeStart - timeNow
                    cell.eventTime.text = "\(remainTimeStart / 60) 时 \(remainTimeStart % 60) 分后"
                }
            }
        } else {
            cell.allDayEvent.isHidden = false
            cell.startTime.isHidden = true
            cell.endTime.isHidden = true
            cell.eventName.text = event.name
            cell.eventPlace.text = event.place
            cell.eventTime.text = "今天"
        }
        cell.eventType.backgroundColor = QSCColor.category(event.category)
        // cell.textLabel?.text = event.name
        //cell.detailTextLabel?.text = event.place + ", " + event.time
        return cell
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .compact) {
            tskList.isHidden = true
            wlanSwitch.isHidden = true
            self.preferredContentSize = maxSize
        } else {
            // max Event count = 9
            tskList.isHidden = false
            wlanSwitch.isHidden = false
            tskList.reloadData()
            // self.preferredContentSize = maxSize
            self.preferredContentSize.height = 110 + CGFloat(events.count) * tskList.rowHeight + 50
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        tskList.rowHeight = 54.0
        //self.preferredContentSize.height = CGFloat(self.events.count + 1) * 44.0
        tskList.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
}
