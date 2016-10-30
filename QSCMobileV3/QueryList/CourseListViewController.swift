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
        
        navigationItem.title = semester.fullNameForSemester
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileManager.getCourses(semester).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Course") as! CourseListCell
        let course = mobileManager.getCourses(semester)[indexPath.row]
        cell.titleLabel.text = course.name
        cell.identifierLabel.text = course.identifier
        cell.creditLabel.text = "学分 " + course.credit!.stringValue
        cell.categoryLabel.text = course.category
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCourse = mobileManager.getCourses(semester)[indexPath.row]
        performSegue(withIdentifier: "showCourseDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CourseDetailViewController
        vc.managedObject = selectedCourse
    }
    
}
