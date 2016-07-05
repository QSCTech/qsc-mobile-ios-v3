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
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.menuViewDelegate = self
        calendarView.calendarDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "EventCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Event")
        
        let rightBorder = CALayer()
        rightBorder.borderColor = QSCColor.dark.CGColor
        rightBorder.borderWidth = 1
        rightBorder.frame = CGRect(x: weekLabel.frame.width, y: 0, width: 1, height: weekLabel.frame.height)
        weekLabel.layer.addSublayer(rightBorder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateForSelectedDate()
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
    
    func updateDateLabel() {
        let calendar = NSCalendar.currentCalendar()
        dayLabel.text = String(calendar.component(.Day, fromDate: selectedDate))
        monthLabel.text = calendar.component(.Month, fromDate: selectedDate).stringForMonth
        yearLabel.text = String(calendar.component(.Year, fromDate: selectedDate))
    }
    
    func updateForSelectedDate() {
        tableView.reloadData()
        calendarView.contentController.refreshPresentedMonth()
        weekLabel.text = weekName
        updateDateLabel()
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
        updateForSelectedDate()
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "全天事项"
        case 1:
            return "日程"
        default:
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let events = mobileManager.eventsForDate(selectedDate)
        switch section {
        case 0:
            return events.filter({ $0.duration == .AllDay }).count
        case 1:
            return events.filter({ $0.duration == .PartialTime }).count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let events: [Event]
        if indexPath.section == 0 {
            events = mobileManager.eventsForDate(selectedDate).filter { $0.duration == .AllDay }
        } else {
            events = mobileManager.eventsForDate(selectedDate).filter { $0.duration == .PartialTime }
        }
        let event = events[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Event") as! EventCell
        cell.nameLabel.text = event.name
        cell.placeLabel.text = event.place
        cell.timeLabel.text = event.time
        var imageName = "Line"
        switch event.category {
        case .Course, .Lesson:
            imageName += "Course"
        case .Exam, .Quiz:
            imageName += "Exam"
        case .Activity:
            imageName += "Activity"
        default:
            imageName += "Todo"
        }
        cell.lineView.image = UIImage(named: imageName)
        return cell
    }
    
}
