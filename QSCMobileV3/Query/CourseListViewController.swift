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
    var selectedCourse: Course!
    
    let mobileManager = MobileManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = semester.substringToIndex(semester.endIndex.advancedBy(-2)) + (semester.hasSuffix("1") ? " 秋冬" : " 春夏")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.getCourses(semester).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Course") as! CourseListCell
        let course = mobileManager.getCourses(semester)[indexPath.row]
        cell.titleLabel.text = course.name
        cell.identifierLabel.text = course.identifier
        cell.creditLabel.text = "学分 " + course.credit!.stringValue
        cell.categoryLabel.text = course.category
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedCourse = mobileManager.getCourses(semester)[indexPath.row]
        performSegueWithIdentifier("showCourseDetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! CourseDetailViewController
        vc.managedObject = selectedCourse
    }
    
}
