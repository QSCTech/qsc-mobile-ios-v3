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

let TodayWidgetSchemeURL = "QSCMobile://todaywidget/"

class TodayViewController: UIViewController {
    
    @IBOutlet weak var taskList: UITableView!
    @IBOutlet weak var firstEventName: UILabel!
    @IBOutlet weak var firstEventPlace: UILabel!
    @IBOutlet weak var firstEventTime: UILabel!
    @IBOutlet weak var firstEventTimePrompt: UILabel!
    @IBOutlet weak var firstEventTimeRemain: UILabel!
    @IBOutlet weak var nothingToDo: UILabel!
    @IBOutlet weak var wlanSwitch: UIButton!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var expandView: UIView!
    
    let events = eventsForDate(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOSApplicationExtension 10, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        taskList.register(UINib(nibName: "TableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Event")
    }
    
    @IBAction func addEvents() {
        extensionContext?.open(URL(string: TodayWidgetSchemeURL + "add")!)
    }
    
    @IBAction func gotoTimetable() {
        extensionContext?.open(URL(string: TodayWidgetSchemeURL + "timetable")!)
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
        let firstEvent = events.first { $0.duration == .partialTime && $0.end >= Date() }
        if let firstEvent = firstEvent {
            firstEventName.text = firstEvent.name
            firstEventPlace.text = firstEvent.place
            firstEventTime.text = firstEvent.time
            if Date() < firstEvent.start {
                firstEventTimePrompt.text = "距开始还有"
                firstEventTimeRemain.text = firstEvent.start.timeIntervalSince(Date()).timeDescription
            } else {
                firstEventTimePrompt.text = "距结束还有"
                firstEventTimeRemain.text = firstEvent.end.timeIntervalSince(Date()).timeDescription
            }
        } else {
            nothingToDo.isHidden = false
            firstView.isHidden = true
        }
        taskList.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .compact) {
            preferredContentSize.height = 110
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
        extensionContext?.open(URL(string: "\(TodayWidgetSchemeURL)detail/\(selectedRow)")!)
        taskList.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row]
        
        let cell = taskList.dequeueReusableCell(withIdentifier: "Event") as! TableViewCell
        
        if event.duration == .partialTime {
            if Calendar.current.isDate(event.start, inSameDayAs: event.end) {
                cell.startTime.text = event.start.stringOfTime
                cell.endTime.text = event.end.stringOfTime
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "MM-dd"
                cell.startTime.text = formatter.string(from: event.start)
                cell.endTime.text = formatter.string(from: event.end)
            }
            cell.eventName.text = event.name
            cell.eventPlace.text = event.place
            if Date() < event.start {
                cell.eventTime.text = "距开始 " + event.start.timeIntervalSince(Date()).timeDescription
            } else if Date() <= event.end {
                cell.eventTime.text = "距结束 " + event.end.timeIntervalSince(Date()).timeDescription
            } else {
                cell.eventTime.text = "已结束"
            }
        }
        cell.eventType.backgroundColor = QSCColor.category(event.category)
        return cell
    }
    
}
