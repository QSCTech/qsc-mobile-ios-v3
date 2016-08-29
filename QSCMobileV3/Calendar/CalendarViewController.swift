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
        calendarView.calendarAppearanceDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "EventCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Event")
        
        let rightBorder = CALayer()
        rightBorder.borderColor = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 0.34).CGColor
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
            let vc = nc.topViewController as! EventEditViewController
            vc.selectedDate = selectedDate
        case "showCourseDetail":
            let vc = segue.destinationViewController as! CourseDetailViewController
            vc.managedObject = selectedEvent.object
        case "showEventDetail":
            let vc = segue.destinationViewController as! EventDetailViewController
            vc.customEvent = selectedEvent.object as! CustomEvent
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
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .VeryShort
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
        let events = eventsForDate(date)
        if events.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        let date = dayView.date.convertedDate()!
        let events = eventsForDate(date)
        var colors = Set<UIColor>()
        for event in events {
            colors.insert(QSCColor.category(event.category))
        }
        // Workaround to display dots in one line
        while colors.count > 3 {
            colors.removeFirst()
        }
        return Array(colors)
    }
    
}

extension CalendarViewController: CVCalendarViewAppearanceDelegate {
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return QSCColor.dark
    }
    
    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return UIColor.blackColor()
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.blackColor()
    }
    
}

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
            return 1
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
            if let holiday = calendarManager.holidayForDate(selectedDate) {
                cell.textLabel!.text = holiday
            } else if let adjustment = calendarManager.adjustmentForDate(selectedDate) {
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy年MM月dd日"
                cell.textLabel!.text = "\(adjustment.name)调休（\(formatter.stringFromDate(adjustment.fromDate))）"
            } else {
                switch semester {
                case .Autumn, .Winter, .Spring, .Summer:
                    cell.textLabel!.text = "\(semester.name)学期第\(calendarManager.weekOrdinalForDate(selectedDate).chinese)周"
                case .WinterMini, .SummerMini:
                    cell.textLabel!.text = semester.name
                case .SummerTime:
                    cell.textLabel!.text = "暑期短学期"
                default:
                    cell.textLabel!.text = ""
                }
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
        case .Bus:
            imageName += "Bus"
        default:
            imageName += "Todo"
        }
        cell.lineView.image = UIImage(named: imageName)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedEvent = filteredEvents(indexPath.section)[indexPath.row]
        if selectedEvent.category == .Course || selectedEvent.category == .Exam {
            performSegueWithIdentifier("showCourseDetail", sender: nil)
        } else {
            performSegueWithIdentifier("showEventDetail", sender: nil)
        }
    }
    
    func filteredEvents(section: Int) -> [Event] {
        let events = eventsForDate(selectedDate)
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
