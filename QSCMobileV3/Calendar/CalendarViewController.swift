//
//  CalendarViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-16.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CVCalendar
import QSCMobileKit

class CalendarViewController: UIViewController {
    
    let mobileManager = MobileManager.sharedInstance
    
    var selectedDate = NSDate()
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.menuViewDelegate = self
        calendarView.calendarDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let rightBorder = CALayer()
        rightBorder.borderColor = QSCColor.dark.CGColor
        rightBorder.borderWidth = 1
        rightBorder.frame = CGRect(x: weekLabel.frame.width, y: 0, width: 1, height: weekLabel.frame.height)
        weekLabel.layer.addSublayer(rightBorder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        calendarView.contentController.refreshPresentedMonth()
        weekLabel.text = weekName
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    @IBAction func changeMode(sender: AnyObject) {
        if calendarView.calendarMode == .WeekView {
            calendarView.changeMode(.MonthView)
            weekLabel.hidden = true
        } else {
            calendarView.changeMode(.WeekView)
            weekLabel.hidden = false
        }
    }
    
    
    @IBAction func toggleToday(sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
    
    var weekName: String {
        let calendarManager = CalendarManager.sharedInstance
        var name = calendarManager.semesterForDate(selectedDate).name
        if name.characters.count == 1 {
            name += calendarManager.weekOrdinalForDate(selectedDate).chinese
        }
        return name
    }
    
}

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        selectedDate = dayView.date.convertedDate()!
        tableView.reloadData()
        calendarView.contentController.refreshPresentedMonth()
        weekLabel.text = weekName
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        let date = dayView.date.convertedDate()!
        let events = mobileManager.eventsForDate(date)
        if events.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        let date = dayView.date.convertedDate()!
        let events = mobileManager.eventsForDate(date)
        var colors = Set<UIColor>()
        for event in events {
            colors.insert(QSCColor.event(event.category))
        }
        return Array(colors)
    }
    
}

// TODO: Check whether logged in
// TODO: Decide whether to use system time zone or UTC+8
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy 年 M 月 d 日"
        return formatter.stringFromDate(selectedDate)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.eventsForDate(selectedDate).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        let course = mobileManager.eventsForDate(selectedDate)[indexPath.row]
        cell.textLabel!.text = course.name
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        cell.detailTextLabel!.attributedText = "\(formatter.stringFromDate(course.start)) - \(formatter.stringFromDate(course.end))".attributedWithHelveticaNeue
        return cell
    }
    
}
