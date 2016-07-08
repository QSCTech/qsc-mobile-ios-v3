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
        return mobileManager.semesterScores.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        let semesterScore = mobileManager.semesterScores[indexPath.row]
        let semester: String
        if semesterScore.semester == "SS" {
            semester = "春夏"
        } else {
            semester = "秋冬"
        }
        cell.textLabel!.text = semesterScore.year! + " " + semester
        return cell
    }
    
}
