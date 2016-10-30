//
//  ExamListViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-08.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class ExamListViewController: UITableViewController {
    
    var semester: String!
    var selectedExam: Exam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = semester.fullNameForSemester
        tableView.registerNib(UINib(nibName: "EventCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Event")
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
    
    var filteredExams: [Exam] {
        return MobileManager.sharedInstance.getExams(semester).filter { $0.startTime != nil }
    }
    
}
