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
        return mobileManager.allSemesters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        let semester = mobileManager.allSemesters.reverse()[indexPath.row]
        cell.textLabel!.text = semester.substringToIndex(semester.endIndex.advancedBy(-2))
        if semester.hasSuffix("1") {
            cell.textLabel!.text! += " 秋冬"
        } else {
            cell.textLabel!.text! += " 春夏"
        }
        return cell
    }
    
}
