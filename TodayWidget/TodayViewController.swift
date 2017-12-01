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
        } else {
            nothingToDo.textColor = UIColor.white
            firstEventName.textColor = UIColor.white
            firstEventTimeRemain.textColor = UIColor.white
            preferredContentSize.height = 110 + CGFloat(events.count > 8 ? 8 : events.count) * taskList.rowHeight + 40
            expandView.isHidden = false
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
        ZjuwlanConnection.link { error in
            if error != nil {
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
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let upcomingEvents = events.filter { $0.end >= Date() }
        if let firstEvent = upcomingEvents.first(where: { $0.duration == .partialTime }) {
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
            firstView.isHidden = true
            nothingToDo.isHidden = false
            if upcomingEvents.contains(where: { $0.duration == .allDay }) {
                nothingToDo.text = "全天事项"
            }
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
            preferredContentSize.height = 110 + CGFloat(events.count > 8 ? 8 : events.count) * taskList.rowHeight + 40
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
        
        cell.eventName.text = event.name
        cell.eventType.backgroundColor = QSCColor.category(event.category)
        cell.eventPlace.text = event.place
        
        if event.duration == .partialTime && Calendar.current.isDate(event.start, inSameDayAs: event.end) {
            cell.startTime.text = event.start.stringOfTime
            cell.endTime.text = event.end.stringOfTime
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
            formatter.dateFormat = "MM-dd"
            cell.startTime.text = formatter.string(from: event.start)
            cell.endTime.text = formatter.string(from: event.end.addingTimeInterval(-1))
        }
        
        if event.duration == .allDay {
            cell.eventTime.text = "全天事项"
        } else if Date() < event.start {
            cell.eventTime.text = "距开始 " + event.start.timeIntervalSince(Date()).timeDescription
        } else if Date() <= event.end {
            cell.eventTime.text = "距结束 " + event.end.timeIntervalSince(Date()).timeDescription
        } else {
            cell.eventTime.text = "已结束"
        }
        
        return cell
    }
    
}
