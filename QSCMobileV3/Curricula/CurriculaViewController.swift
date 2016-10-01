//
//  CurriculaViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-09-14.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CurriculaTable
import QSCMobileKit

private let bgColors = [
    UIColor(red: 1.0, green: 0.73, blue: 0.0, alpha: 1.0),
    UIColor(red: 0.0, green: 0.83, blue: 0.62, alpha: 1.0),
    UIColor(red: 0.78, green: 0.49, blue: 0.87, alpha: 1.0),
    UIColor(red: 1.0, green: 0.52, blue: 0.11, alpha: 1.0),
    UIColor(red: 0.42, green: 0.60, blue: 0.98, alpha: 1.0),
    UIColor(red: 1.0, green: 0.43, blue: 0.51, alpha: 1.0),
    UIColor(red: 0.0, green: 0.69, blue: 0.95, alpha: 1.0),
    UIColor(red: 0.46, green: 0.82, blue: 0.0, alpha: 1.0),
]

class CurriculaViewController: UIViewController {
    
    init() {
        super.init(nibName: "CurriculaViewController", bundle: NSBundle.mainBundle())
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var curriculaTable: CurriculaTable!
    
    private let mobileManager = MobileManager.sharedInstance
    private let calendarManager = CalendarManager.sharedInstance
    
    private var currentIndex = -1
    private var maxIndex: Int {
        return mobileManager.allSemesters.count * 2 - 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "一周课表"
        titleLabel.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        previousButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        nextButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        currentIndex = maxIndex - 1
        let semester = calendarManager.semesterForDate(NSDate())
        if semester == .Winter || semester == .Summer {
            currentIndex += 1
        }
        updateIndex()
    }
    
    @IBAction func goToPrevious(sender: AnyObject) {
        if currentIndex > 0 {
            currentIndex -= 1
            updateIndex()
        }
    }
    
    @IBAction func goToNext(sender: AnyObject) {
        if currentIndex < maxIndex {
            currentIndex += 1
            updateIndex()
        }
    }
    
    func checkBounds() {
        if currentIndex == 0 {
            previousButton.enabled = false
        } else {
            previousButton.enabled = true
        }
        if currentIndex == maxIndex {
            nextButton.enabled = false
        } else {
            nextButton.enabled = true
        }
    }
    
    func updateIndex() {
        if currentIndex < 0 || currentIndex > maxIndex {
            return
        }
        checkBounds()
        let semester = mobileManager.allSemesters[currentIndex / 2]
        let courses: [Course]
        if currentIndex % 2 == 0 {
            courses = mobileManager.getCourses(semester).filter { $0.semester!.includesSemester(.Autumn) || $0.semester!.includesSemester(.Spring) }
            titleLabel.text = semester.fullNameForSemester.stringByReplacingOccurrencesOfString("冬", withString: "").stringByReplacingOccurrencesOfString("夏", withString: "") + "学期"
        } else {
            courses = mobileManager.getCourses(semester).filter { $0.semester!.includesSemester(.Winter) || $0.semester!.includesSemester(.Summer) }
            titleLabel.text = semester.fullNameForSemester.stringByReplacingOccurrencesOfString("秋", withString: "").stringByReplacingOccurrencesOfString("春", withString: "") + "学期"
        }
        var curricula = [CurriculaTableItem]()
        for (index, course) in courses.enumerate() {
            for timePlace in course.timePlaces! {
                let timePlace = timePlace as! TimePlace
                let name = "\(course.name!)（\(timePlace.week!)）".stringByReplacingOccurrencesOfString("（每周）", withString: "")
                let weekday = CurriculaTableWeekday(rawValue: timePlace.weekday!.integerValue)!
                let startPeriod = Int(timePlace.periods!.substringToIndex(timePlace.periods!.startIndex.successor()), radix: 16)!
                let endPeriod = Int(timePlace.periods!.substringFromIndex(timePlace.periods!.endIndex.predecessor()), radix: 16)!
                let bgColor = bgColors[index % bgColors.count]
                let curriculum = CurriculaTableItem(name: name, place: timePlace.place!, weekday: weekday, startPeriod: startPeriod, endPeriod: endPeriod, textColor: UIColor.whiteColor(), bgColor: bgColor) { curriculum in
                    return
                }
                curricula.append(curriculum)
            }
        }
        curriculaTable.curricula = curricula
        curriculaTable.textEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        curriculaTable.bgColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        curriculaTable.borderWidth = 0.5
        curriculaTable.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        curriculaTable.cornerRadius = 5
    }
    
}
