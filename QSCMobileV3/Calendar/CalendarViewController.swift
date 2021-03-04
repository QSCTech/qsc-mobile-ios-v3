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
    
    var selectedDate = UTC8Date()
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
        tableView.register(UINib(nibName: "EventCell", bundle: Bundle.main), forCellReuseIdentifier: "Event")
        
       // navigationController?.navigationBar.barTintColor = ColorCompatibility.systemGray6
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorCompatibility.label]
        tableView?.backgroundColor = ColorCompatibility.systemBackground
        view.backgroundColor = ColorCompatibility.systemBackground
        calendarView.backgroundColor = ColorCompatibility.systemBackground
        
        NotificationCenter.default.addObserver(forName: .eventsModified, object: nil, queue: .main) { notification in
            if let start = notification.userInfo?["start"] as? Date, let end = notification.userInfo?["end"] as? Date {
                var date = self.chineseCalendar.startOfDay(for: start)
                while date <= end {
                    self.cache.removeValue(forKey: date)
                    date = date.addingTimeInterval(86400)
                }
            } else {
                self.cache.removeAll()
            }
        }
        NotificationCenter.default.addObserver(forName: .refreshCompleted, object: nil, queue: .main) { _ in
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateForSelectedDate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "addEvent":
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! EventEditViewController
            vc.selectedDate = selectedDate
            vc.delegate = self
        case "showCourseDetail":
            let vc = segue.destination as! CourseDetailViewController
            vc.managedObject = selectedEvent.object
            vc.hidesBottomBarWhenPushed = true
        case "showEventDetail":
            let vc = segue.destination as! EventDetailViewController
            vc.customEvent = (selectedEvent.object as! CustomEvent)
        default:
            break
        }
    }
    
    @IBAction func changeMode(_ sender: AnyObject) {
        if calendarView.calendarMode == .weekView {
            calendarView.changeMode(.monthView)
            weekLabel.isHidden = true
        } else {
            calendarView.changeMode(.weekView)
            weekLabel.isHidden = false
        }
    }
    
    @IBAction func toggleToday(_ sender: AnyObject) {
        calendarView.toggleCurrentDayView()
    }
    
    var chineseCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return calendar
    }()
    
    var weekName: String {
        var name = calendarManager.semesterForDate(selectedDate).name
        if name.count == 1 {
            name += calendarManager.weekOrdinalForDate(selectedDate).chinese
        }
        return name
    }
    
    func updateDateLabel() {
        dayLabel.text = String(chineseCalendar.component(.day, from: selectedDate))
        monthLabel.text = chineseCalendar.component(.month, from: selectedDate).stringForMonth
        yearLabel.text = String(chineseCalendar.component(.year, from: selectedDate))
    }
    
    func updateForSelectedDate() {
        _ = calculatedColorsForDate(selectedDate)
        tableView.reloadData()
        calendarView.contentController?.refreshPresentedMonth()
        weekLabel.text = weekName
        updateDateLabel()
    }
    
    
    var cache = [Date: Set<UIColor>]()
    
    func cachedColorsForDate(_ date: Date) -> Set<UIColor> {
        if let colors = cache[date] {
            return colors
        }
        return calculatedColorsForDate(date)
    }
    
    func calculatedColorsForDate(_ date: Date) -> Set<UIColor> {
        let events = eventsForDate(date)
        var colors = Set<UIColor>()
        for event in events {
            colors.insert(QSCColor.category(event.category))
        }
        cache[date] = colors
        return colors
    }
    
}

// MARK: - CVCalendarViewDelegate
extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .weekView
    }
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .veryShort
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        selectedDate = dayView.date.convertedDate(calendar: chineseCalendar)!
        updateForSelectedDate()
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        let date = dayView.date.convertedDate(calendar: chineseCalendar)!
        let colors = cachedColorsForDate(date)
        return !colors.isEmpty
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        let date = dayView.date.convertedDate(calendar: chineseCalendar)!
        var colors = cachedColorsForDate(date)
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
        return UIColor.black
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.black
    }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        return ColorCompatibility.label
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _):
            return ColorCompatibility.systemGray5
        default:
            return nil
        }
    }
    
    func dayOfWeekBackGroundColor() -> UIColor {
        return ColorCompatibility.systemBackground
    }
    
}

// TODO: Decide whether to use system time zone or UTC+8

// MARK: - UITableView{Delegate,DataSource}
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let events = filteredEvents(section)
        if section == 0 {
            return 1
        } else {
            return events.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 30
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel?.textColor = ColorCompatibility.label
            cell.contentView.backgroundColor = ColorCompatibility.systemBackground
            let semester = calendarManager.semesterForDate(selectedDate)
            if let holiday = calendarManager.holidayForDate(selectedDate) {
                cell.textLabel!.text = holiday
            } else if let adjustment = calendarManager.adjustmentForDate(selectedDate) {
                cell.textLabel!.text = "\(adjustment.name)调休（\(adjustment.fromDate.stringOfDate)）"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Event") as! EventCell
        cell.nameLabel.text = event.name
        cell.placeLabel.text = event.place
        cell.timeLabel.text = event.time
        var imageName = "Line"
        switch event.category {
        case .course, .lesson:
            imageName += "Course"
        case .exam, .quiz:
            imageName += "Exam"
        case .activity:
            imageName += "Activity"
        case .todo:
            imageName += "Todo"
        case .bus:
            imageName += "Bus"
        }
        cell.lineView.image = UIImage(named: imageName)
        
        cell.backgroundColor = ColorCompatibility.systemBackground
        cell.nameLabel.textColor = ColorCompatibility.label
        cell.contentView.backgroundColor = UIColor(white: 1, alpha: 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        selectedEvent = filteredEvents(indexPath.section)[indexPath.row]
        if selectedEvent.category == .course || selectedEvent.category == .exam {
            performSegue(withIdentifier: "showCourseDetail", sender: nil)
        } else {
            performSegue(withIdentifier: "showEventDetail", sender: nil)
        }
    }
    
    func filteredEvents(_ section: Int) -> [Event] {
        let events = eventsForDate(selectedDate)
        switch section {
        case 1:
            return events.filter { $0.duration == .allDay }
        case 2:
            return events.filter { $0.duration == .partialTime }
        default:
            return events
        }
    }
    
}

extension CalendarViewController: EventEditViewControllerDelegate {
    func reloadTableView() {
        self.viewWillAppear(true)
    }
}
