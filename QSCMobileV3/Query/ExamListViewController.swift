//
//  ExamListViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-08.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

let ShowAllCoursesKey = "ShowAllCourses"

class ExamListViewController: UITableViewController {
    
    var semester: String!
    var selectedExam: Exam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "EventCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Event")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: groupDefaults.boolForKey(ShowAllCoursesKey) ? "隐藏无考试的课程" : "显示无考试的课程", style: .Plain, target: self, action: #selector(changeCoursesShowMode))
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredExams.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Event") as! EventCell
        cell.lineView.image = UIImage(named: "LineExam")
        let exam = filteredExams[indexPath.row]
        cell.nameLabel.text = exam.name
        if exam.startTime != nil {
            cell.placeLabel.text = exam.place
            if !exam.seat!.isEmpty {
                cell.placeLabel.text! += " #" + exam.seat!
            }
            cell.timeLabel.text = exam.time
        } else {
            cell.placeLabel.text = "-"
            cell.timeLabel.text = "-"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedExam = filteredExams[indexPath.row]
        performSegueWithIdentifier("showCourseDetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! CourseDetailViewController
        vc.managedObject = selectedExam
    }
    
    func changeCoursesShowMode(sender: AnyObject) {
        groupDefaults.setBool(!groupDefaults.boolForKey(ShowAllCoursesKey), forKey: ShowAllCoursesKey)
        navigationItem.rightBarButtonItem!.title = groupDefaults.boolForKey(ShowAllCoursesKey) ? "隐藏无考试的课程" : "显示无考试的课程"
        tableView.reloadData()
    }
    
    var filteredExams: [Exam] {
        return MobileManager.sharedInstance.getExams(semester).filter {
            groupDefaults.boolForKey(ShowAllCoursesKey) || $0.startTime != nil
        }
    }
    
}
