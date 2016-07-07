//
//  CourseDetailViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-06.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
import QSCMobileKit

class CourseDetailViewController: UITableViewController {
    
    var managedObject: NSManagedObject!
    var courseObject: Course?
    var examObject: Exam?
    var scoreObject: Score?
    var courseEvent: CourseEvent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let identifier = managedObject.valueForKey("identifier") as? String {
            (courseObject, examObject, scoreObject) = MobileManager.sharedInstance.objectTripleWithIdentifier(identifier)
            courseEvent = EventManager.sharedInstance.courseEventForIdentifier(identifier)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private enum Detail: Int {
        case Basic = 0, Exam, Info, Homework
        static let count = 4
    }
    
    private let infos = [
        [
            "title": "教师",
            "key": "teacher",
        ],
        [
            "title": "电子邮箱",
            "key": "email",
        ],
        [
            "title": "联系电话",
            "key": "phone",
        ],
        [
            "title": "课程网站",
            "key": "website",
        ],
        [
            "title": "QQ 群",
            "key": "qqGroup",
        ],
        [
            "title": "公共邮箱",
            "key": "publicEmail",
        ],
        [
            "title": "公邮密码",
            "key": "publicPassword",
        ],
    ]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Detail.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Detail.Basic.rawValue:
            return courseObject!.timePlaces!.count + 1
        case Detail.Exam.rawValue:
            return 2
        case Detail.Info.rawValue:
            var count = 0
            for info in infos {
                if courseEvent.valueForKey(info["key"]!) != nil {
                    count += 1
                }
            }
            return count
        case Detail.Homework.rawValue:
            return courseEvent.homeworks!.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case Detail.Basic.rawValue:
            switch indexPath.row {
            case 0:
                return 66
            default:
                return 60
            }
        case Detail.Exam.rawValue:
            if indexPath.row == 1 && examObject?.startTime != nil {
                return 60
            } else {
                return 44
            }
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Detail.Basic.rawValue:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("Name") as! CourseNameCell
                cell.nameLabel.text = courseObject!.name
                cell.identifierLabel!.text = courseObject!.identifier
                cell.categoryLabel!.text = courseObject!.category
                if managedObject as? Course != nil {
                    cell.dotView.backgroundColor = QSCColor.course
                } else if managedObject as? Exam != nil {
                    cell.dotView.backgroundColor = QSCColor.exam
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("TimePlace") as! CourseTimePlaceCell
                let sortDescriptors = [NSSortDescriptor(key: "weekday", ascending: true), NSSortDescriptor(key: "periods", ascending: true)]
                let timePlace = courseObject!.timePlaces!.sortedArrayUsingDescriptors(sortDescriptors)[indexPath.row - 1] as! TimePlace
                cell.placeLabel!.text = timePlace.place!
                cell.timeLabel!.text = timePlace.time!
                return cell
            }
        case Detail.Exam.rawValue:
            switch indexPath.row {
            case 1:
                if let examObject = examObject, _ = examObject.startTime {
                    let cell = tableView.dequeueReusableCellWithIdentifier("TimePlace") as! CourseTimePlaceCell
                    cell.placeLabel!.text = examObject.place
                    if !examObject.seat!.isEmpty {
                        cell.placeLabel!.text! += " #" + examObject.seat!
                    }
                    cell.timeLabel!.text = examObject.time
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                    cell.selectionStyle = .None
                    cell.textLabel!.text = "暂无考试信息"
                    cell.detailTextLabel!.text = ""
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.selectionStyle = .None
                cell.textLabel!.text = "学分：" + courseObject!.credit!.stringValue
                if let scoreObject = scoreObject {
                    cell.detailTextLabel!.text =  "成绩：" + scoreObject.gradePoint!.stringValue + " / " + scoreObject.score!
                } else {
                    cell.detailTextLabel!.text = "暂无成绩信息"
                }
                if !groupDefaults.boolForKey(ShowScoreKey) {
                    cell.detailTextLabel!.text = ""
                }
                return cell
            }
        case Detail.Info.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
            cell.textLabel!.text = infos[indexPath.row]["title"]
            cell.detailTextLabel!.text = courseEvent.valueForKey(infos[indexPath.row]["key"]!) as? String
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case Detail.Info.rawValue:
            switch indexPath.row {
            case 0:
                if #available(iOS 9.0, *) {
                    let url = "http://chalaoshi.cn/search?q=" + courseObject!.teacher!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    let svc = SFSafariViewController(URL: NSURL(string: url)!)
                    presentViewController(svc, animated: true, completion: nil)
                }
            default:
                break
            }
        default:
            break
        }
    }
    
}
