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

class TodayViewController: UIViewController {
    
    @IBOutlet var taskList: UITableView!
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
    @IBOutlet var addButton: UIButton!
    @IBOutlet var timetableButton: UIButton!
    @IBOutlet var expandView: UIView!
    
    // TODO: Support multi-day events and refresh when one day passed
    // let events = eventsForDate(Date()).filter { Calendar.current.isDate($0.start, inSameDayAs: $0.end) }
    let events = eventsForDate(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOSApplicationExtension 10, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        taskList.register(UINib(nibName: "TableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Event")
    }
    
    @IBAction func addEvents() {
        extensionContext?.open(URL(string: "QSCMobile://tw/add")!, completionHandler: nil)
    }
    
    @IBAction func gotoTimetable() {
        extensionContext?.open(URL(string: "QSCMobile://tw/timetable")!, completionHandler: nil)
    }
    
    @IBAction func connectWlan() {
        wlanSwitch.setImage(UIImage.init(named: "WiFiConnecting"), for: .normal)
        ZjuwlanConnection.link { success, error in
            if success {
                self.wlanSwitch.setImage(UIImage.init(named: "WiFiSuccess"), for: .normal)
            } else {
                self.wlanSwitch.setImage(UIImage.init(named: "WiFiFailed"), for: .normal)
                delay(1) {
                    self.wlanSwitch.setImage(UIImage.init(named: "WiFi"), for: .normal)
                }
            }
        }
    }
    
}

extension TodayViewController: NCWidgetProviding {
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let firstEvent = events.first { $0.duration == .partialTime && $0.end >= Date() && Calendar.current.isDate($0.start, inSameDayAs: $0.end) }
        if let firstEvent = firstEvent {
            firstEventName.text = firstEvent.name
            firstEventPlace.text = firstEvent.place
            firstEventTime.text = firstEvent.time
            if Date() < firstEvent.start {
                firstEventTimeType.text = "距开始还有"
                firstEventTimeRemain.text = firstEvent.start.timeIntervalSince(Date()).timeDescription
            } else {
                firstEventTimeType.text = "距结束还有"
                firstEventTimeRemain.text = firstEvent.end.timeIntervalSince(Date()).timeDescription
            }
        } else {
            nothingToDo.isHidden = false
            line.isHidden = true
            firstEventName.isHidden = true
            firstEventTime.isHidden = true
            firstEventPlace.isHidden = true
            firstEventTimeType.isHidden = true
            firstEventTimeRemain.isHidden = true
            placeIcon.isHidden = true
            timeIcon.isHidden = true
        }
        taskList.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .compact) {
            self.preferredContentSize.height = 110
            expandView.isHidden = true
        } else {
            self.preferredContentSize.height = 110 + CGFloat(events.count > 8 ? 8 : events.count) * taskList.rowHeight + 40
            expandView.isHidden = false
        }
    }
    
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count > 8 ? 8 : events.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        self.extensionContext?.open(URL(string: "QSCMobile://tw/detail/\(selectedRow)")!, completionHandler: nil)
        taskList.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        
        let cell = taskList.dequeueReusableCell(withIdentifier: "Event") as! TableViewCell
        
        if event.duration == .partialTime {
            if Calendar.current.isDate(event.start, inSameDayAs: event.end) {
                cell.startTime.text = event.start.stringOfTime
                cell.endTime.text = event.end.stringOfTime
                cell.eventName.text = event.name
                cell.eventPlace.text = event.place
                if Date() < event.start {
                    cell.eventTime.text = "距开始 " + event.start.timeIntervalSince(Date()).timeDescription
                } else if Date() <= event.end {
                    cell.eventTime.text = "距结束 " + event.end.timeIntervalSince(Date()).timeDescription
                } else {
                    cell.eventTime.text = "已结束"
                }
            } else {
                cell.startTime.text = event.start.stringOfDate.components(separatedBy: "年").last!.replacingOccurrences(of: "月", with: "/").replacingOccurrences(of: "日", with: "")
                cell.endTime.text = event.end.stringOfDate.components(separatedBy: "年").last!.replacingOccurrences(of: "月", with: "/").replacingOccurrences(of: "日", with: "")
                cell.eventName.text = event.name
                cell.eventPlace.text = event.place
                cell.eventTime.text = "今天"
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
        return cell
    }
    
}
