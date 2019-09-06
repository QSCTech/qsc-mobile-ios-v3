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
        
        if source == .course {
            navigationItem.title = "课程一览"
        } else {
            navigationItem.title = "考试一览"
        }
        if #available(iOS 13, *) {
            self.view.backgroundColor = UIColor.systemBackground
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.allSemesters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Semester") as! SemesterListCell
        let semester = mobileManager.allSemesters.reversed()[indexPath.row]
        cell.titleLabel.text = semester.fullNameForSemester
        cell.titleLabel.textColor = ColorCompatibility.label
        let courses = mobileManager.getCourses(semester)
        cell.subtitleLabel.text = "\(courses.count) 门课程"
        if source == .course {
            let credit = courses.reduce(0.0) { $0 + mobileManager.courseCreditWithIdentifier($1.identifier!) }
            cell.subtitleLabel.text! += "，共 \(credit) 学分"
            cell.subtitleLabel.textColor = QSCColor.course
        } else {
            let exams = mobileManager.getExams(semester)
            cell.subtitleLabel.text! += "，\(exams.filter({ $0.startTime != nil }).count) 场考试"
            cell.subtitleLabel.textColor = QSCColor.exam
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedSemester = mobileManager.allSemesters.reversed()[indexPath.row]
        if source == .course {
            performSegue(withIdentifier: "showCourseList", sender: nil)
        } else {
            performSegue(withIdentifier: "showExamList", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        segue.destination.setValue(selectedSemester, forKey: "semester")
        if let vc = segue.destination as? CourseListViewController {
            vc.semester = selectedSemester
        } else if let vc = segue.destination as? ExamListViewController {
            vc.semester = selectedSemester
        }
    }
    
}
