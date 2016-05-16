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
    
    @IBOutlet weak var monthViewButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.menuViewDelegate = self
        calendarView.calendarDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        monthViewButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: 20)!], forState: .Normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
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
        return true
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        selectedDate = dayView.date.convertedDate()!
        tableView.reloadData()
    }
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "zh_CN")
        formatter.dateFormat = "yyyy 年 M 月 d 日（EEE）"
        return formatter.stringFromDate(selectedDate)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.coursesForDate(selectedDate).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        let course = mobileManager.coursesForDate(selectedDate)[indexPath.row]
        cell.textLabel!.text = course.name
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        cell.detailTextLabel!.text = "\(formatter.stringFromDate(course.start)) - \(formatter.stringFromDate(course.end))"
        return cell
    }
    
}
