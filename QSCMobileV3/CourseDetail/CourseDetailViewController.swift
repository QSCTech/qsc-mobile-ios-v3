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
import MessageUI
import SVProgressHUD
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
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(edit))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if managedObject.managedObjectContext == nil {
            navigationController?.popViewControllerAnimated(true)
        } else {
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = (segue.destinationViewController as! UINavigationController).topViewController as! CourseEditViewController
        vc.courseEvent = courseEvent
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
                if let value = courseEvent.valueForKey(info["key"]!) as? String {
                    if !value.isEmpty {
                        count += 1
                    }
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
                    cell.textLabel!.text = "无考试信息"
                    cell.detailTextLabel!.text = ""
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.selectionStyle = .None
                cell.textLabel!.text = "学分：" + courseObject!.credit!.stringValue
                if let scoreObject = scoreObject {
                    cell.detailTextLabel!.text =  String(format: "成绩：%.1f / %@", scoreObject.gradePoint!.floatValue, scoreObject.score!)
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
            var values = [(String, String)]()
            for info in infos {
                if let value = courseEvent.valueForKey(info["key"]!) as? String {
                    if !value.isEmpty {
                        values.append((info["title"]!, value))
                    }
                }
            }
            cell.textLabel!.text = values[indexPath.row].0
            cell.detailTextLabel!.text = values[indexPath.row].1
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case Detail.Info.rawValue:
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            switch cell.textLabel!.text! {
            case infos[0]["title"]!:
                let url = NSURL(string: "http://chalaoshi.cn/search?q=" + courseEvent.teacher!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(URL: url)
                    presentViewController(svc, animated: true, completion: nil)
                }
            case infos[1]["title"]!:
                let mcvc = MFMailComposeViewController()
                mcvc.mailComposeDelegate = self
                mcvc.setToRecipients([courseEvent.email!])
                presentViewController(mcvc, animated: true, completion: nil)
            case infos[2]["title"]!:
                UIApplication.sharedApplication().openURL(NSURL(string: "telprompt:" + courseEvent.phone!)!)
            case infos[3]["title"]!:
                var prefix = ""
                if !courseEvent.website!.containsString("://") {
                    prefix = "http://"
                } else if !courseEvent.website!.hasPrefix("http") {
                    prefix = "不支持 "
                }
                if let url = NSURL(string: prefix + courseEvent.website!) {
                    if #available(iOS 9.0, *) {
                        let svc = SFSafariViewController(URL: url)
                        presentViewController(svc, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "课程网站", message: "浏览器无法打开链接", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好", style: .Default, handler: nil)
                    alert.addAction(action)
                    presentViewController(alert, animated: true, completion: nil)
                }
            default:
                let pasteboard = UIPasteboard.generalPasteboard()
                pasteboard.string = cell.detailTextLabel!.text
                SVProgressHUD.showSuccessWithStatus("已拷贝到剪贴板")
            }
        default:
            break
        }
    }
    
    func edit(sender: AnyObject) {
        performSegueWithIdentifier("Edit", sender: nil)
    }
    
}

extension CourseDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
