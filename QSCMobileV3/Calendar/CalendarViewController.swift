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

// MARK: - UIViewController
class CalendarViewController: UIViewController {
    
    let mobileManager = MobileManager.sharedInstance
    let calendarManager = CalendarManager.sharedInstance
    
    var selectedDate = NSDate()
    var selectedEvent: Event!
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "addEvent":
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! AddEventViewController
            vc.selectedDate = selectedDate
        case "showCourseDetail":
            let vc = segue.destinationViewController as! CourseDetailViewController
            vc.courseObject = selectedEvent.object as! Course
            vc.courseEvent = EventManager.sharedInstance.courseEventForIdentifier(vc.courseObject.identifier!)
        default:
            break
        }
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

// MARK: - CVCalendarViewDelegate
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

// MARK: - UITableView{Delegate,DataSource}
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredEvents(section).isEmpty {
            return nil
        } else if section == 1 {
            return "全天事项"
        } else if section == 2 {
            return "日程"
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let events = filteredEvents(section)
        if section == 0 {
            let semester = calendarManager.semesterForDate(selectedDate)
            let holidays: [CalendarSemester] = [.WinterMini, .SummerMini, .SummerTime]
            return Int(calendarManager.holidayForDate(selectedDate) != nil || calendarManager.adjustmentForDate(selectedDate) != nil || holidays.contains(semester) || events.count == 0)
        } else {
            return events.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 30
        } else {
            return 80
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
            let semester = calendarManager.semesterForDate(selectedDate)
            let holidays: [CalendarSemester] = [.WinterMini, .SummerMini, .SummerTime]
            if let holiday = calendarManager.holidayForDate(selectedDate) {
                cell.textLabel!.text = holiday
            } else if let adjustment = calendarManager.adjustmentForDate(selectedDate) {
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy年MM月dd日"
                cell.textLabel!.text = "\(adjustment.name)调休（\(formatter.stringFromDate(adjustment.fromDate))）"
            } else if holidays.contains(semester) {
                if semester == .SummerTime {
                    cell.textLabel!.text = "暑期短学期"
                } else {
                    cell.textLabel!.text = semester.name
                }
            } else {
                cell.textLabel!.text = "本日无事"
            }
            return cell
        }
        
        let event = filteredEvents(indexPath.section)[indexPath.row]
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedEvent = filteredEvents(indexPath.section)[indexPath.row]
        if selectedEvent.category == .Course {
            performSegueWithIdentifier("showCourseDetail", sender: nil)
        }
    }
    
    func filteredEvents(section: Int) -> [Event] {
        let events = mobileManager.eventsForDate(selectedDate)
        switch section {
        case 1:
            return events.filter { $0.duration == .AllDay }
        case 2:
            return events.filter { $0.duration == .PartialTime }
        default:
            return events
        }
    }
    
}
