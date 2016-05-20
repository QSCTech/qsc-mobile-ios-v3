//
//  CalendarMonthViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-16.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CVCalendar
import QSCMobileKit

class CalendarMonthViewController: UIViewController {
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    var calendarViewController: CalendarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.menuViewDelegate = self
        calendarView.calendarDelegate = self
        navItem.title = CVDate(date: NSDate()).globalDescription
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    func returnToDate(date: NSDate?) {
        self.navigationController!.popViewControllerAnimated(true)
        if let date = date {
            calendarViewController!.calendarView.toggleViewWithDate(date)
        } else {
            calendarViewController!.calendarView.toggleCurrentDayView()
        }
    }
    
    @IBAction func todayButton(sender: AnyObject) {
        returnToDate(NSDate())
    }
    
}

extension CalendarMonthViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    func presentedDateUpdated(date: Date) {
        navItem.title = date.globalDescription
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        delay(0.5) {
            self.returnToDate(dayView.date.convertedDate())
        }
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
}
