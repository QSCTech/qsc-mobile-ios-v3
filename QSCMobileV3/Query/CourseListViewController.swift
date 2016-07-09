//
//  CourseListViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-08.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class CourseListViewController: UITableViewController {
    
    var semester: String!
    
    let mobileManager = MobileManager.sharedInstance
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.getCourses(semester).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        let course = mobileManager.getCourses(semester)[indexPath.row]
        cell.textLabel!.text = course.name
        cell.detailTextLabel!.text = course.identifier
        return cell
    }
    
}
