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
    
    let mobileManager = MobileManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "EventCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Event")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.getExams(semester).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Event") as! EventCell
        cell.lineView.image = UIImage(named: "LineExam")
        let exam = mobileManager.getExams(semester)[indexPath.row]
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
    
}
