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

class CurriculaViewController: UIViewController {
    
    init() {
        super.init(nibName: "CurriculaViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var curriculaTable: CurriculaTable!
    
    let mobileManager = MobileManager.sharedInstance
    let calendarManager = CalendarManager.sharedInstance
    
    var currentIndex = -1
    var maxIndex: Int {
        return mobileManager.allSemesters.count * 2 - 1
    }
    
//    let bgColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0)
//    let bgColor = UIColor.systemGray5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemGray6
            titleLabel.backgroundColor = UIColor.systemGray6
            titleLabel.textColor = UIColor.label
            nextButton.setTitleColor(UIColor.label, for: .normal)
            nextButton.setTitleColor(UIColor.systemGray, for: .highlighted)
            nextButton.setTitleColor(UIColor.systemGray, for: .disabled)
            previousButton.setTitleColor(UIColor.label, for: .normal)
            previousButton.setTitleColor(UIColor.systemGray, for: .highlighted)
            previousButton.setTitleColor(UIColor.systemGray, for: .disabled)
        } else {
            view.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0)
            titleLabel.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0)
            previousButton.setTitleColor(UIColor.lightGray, for: .disabled)
            nextButton.setTitleColor(UIColor.lightGray, for: .disabled)
        }
        navigationItem.title = "一周课表"
        currentIndex = maxIndex - 1
        let semester = calendarManager.semesterForDate(Date())
        if semester == .Winter || semester == .Summer {
            currentIndex += 1
        }
        updateIndex()
    }
    
    @IBAction func goToPrevious(_ sender: AnyObject) {
        if currentIndex > 0 {
            currentIndex -= 1
            updateIndex()
        }
    }
    
    @IBAction func goToNext(_ sender: AnyObject) {
        if currentIndex < maxIndex {
            currentIndex += 1
            updateIndex()
        }
    }
    
    func checkBounds() {
        if currentIndex == -1 {
            previousButton.isEnabled = false
            nextButton.isEnabled = false
            return
        }
        if currentIndex == 0 {
            previousButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
        }
        if currentIndex == maxIndex {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
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
            titleLabel.text = semester.fullNameForSemester.replacingOccurrences(of: "冬", with: "").replacingOccurrences(of: "夏", with: "") + "学期"
        } else {
            courses = mobileManager.getCourses(semester).filter { $0.semester!.includesSemester(.Winter) || $0.semester!.includesSemester(.Summer) }
            titleLabel.text = semester.fullNameForSemester.replacingOccurrences(of: "秋", with: "").replacingOccurrences(of: "春", with: "") + "学期"
        }
        var curricula = [CurriculaTableItem]()
        for course in courses {
            for timePlace in course.timePlaces! {
                let timePlace = timePlace as! TimePlace
                let name = "\(course.name!)（\(timePlace.week!)）".replacingOccurrences(of: "（每周）", with: "")
                let weekday = CurriculaTableWeekday(rawValue: timePlace.weekday!.intValue)!
                let startPeriod = Int(String(timePlace.periods![timePlace.periods!.startIndex]), radix: 16)!
                let endPeriod = Int(String(timePlace.periods![timePlace.periods!.index(before: timePlace.periods!.endIndex)]), radix: 16)!
                let curriculum = CurriculaTableItem(name: name, place: timePlace.place!, weekday: weekday, startPeriod: startPeriod, endPeriod: endPeriod, textColor: ColorCompatibility.curriculaLabel, bgColor: QSCColor.theme, identifier: course.identifier!) { curriculum in
                    let sb = UIStoryboard(name: "CourseDetail", bundle: Bundle.main)
                    let vc = sb.instantiateInitialViewController() as! CourseDetailViewController
                    vc.managedObject = self.mobileManager.courseObjectsWithIdentifier(curriculum.identifier).first!
                    self.show(vc, sender: nil)
                }
                curricula.append(curriculum)
            }
        }
        curriculaTable.curricula = curricula
        if #available(iOS 13.0, *) {
            curriculaTable.bgColor = UIColor.systemGray6
            curriculaTable.borderColor = UIColor.systemGray5
        } else {
            curriculaTable.bgColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0)
            curriculaTable.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        }
        curriculaTable.borderWidth = 0.5
        
        curriculaTable.cornerRadius = 2
        curriculaTable.rectEdgeInsets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
        curriculaTable.textEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        curriculaTable.textAlignment = .center
    }
    
}
