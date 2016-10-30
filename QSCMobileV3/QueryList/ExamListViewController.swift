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
        tableView.register(UINib(nibName: "EventCell", bundle: Bundle.main), forCellReuseIdentifier: "Event")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredExams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Event") as! EventCell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedExam = filteredExams[indexPath.row]
        performSegue(withIdentifier: "showCourseDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CourseDetailViewController
        vc.managedObject = selectedExam
    }
    
    var filteredExams: [Exam] {
        return MobileManager.sharedInstance.getExams(semester).filter { $0.startTime != nil }
    }
    
}
