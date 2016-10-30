//
//  SemesterListViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-08.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class SemesterListViewController: UITableViewController {
    
    var source: Event.Category!
    var selectedSemester: String!
    
    let mobileManager = MobileManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if source == .Course {
            navigationItem.title = "课程一览"
        } else {
            navigationItem.title = "考试一览"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.allSemesters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Semester") as! SemesterListCell
        let semester = mobileManager.allSemesters.reverse()[indexPath.row]
        cell.titleLabel.text = semester.fullNameForSemester
        let courses = mobileManager.getCourses(semester)
        let exams = mobileManager.getExams(semester)
        cell.subtitleLabel.text = "\(courses.count) 门课程"
        if source == .Course {
            cell.subtitleLabel.text! += "，共 \(courses.reduce(0.0) { $0 + $1.credit!.floatValue }) 学分"
            cell.subtitleLabel.textColor = QSCColor.course
        } else {
            cell.subtitleLabel.text! += "，\(exams.filter({ $0.startTime != nil }).count) 场考试"
            cell.subtitleLabel.textColor = QSCColor.exam
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedSemester = mobileManager.allSemesters.reverse()[indexPath.row]
        if source == .Course {
            performSegueWithIdentifier("showCourseList", sender: nil)
        } else {
            performSegueWithIdentifier("showExamList", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController
        vc.setValue(selectedSemester, forKey: "semester")
    }
    
}
