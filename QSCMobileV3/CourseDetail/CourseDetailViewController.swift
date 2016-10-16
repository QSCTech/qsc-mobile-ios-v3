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
    
    var managedObject: NSManagedObject! {
        didSet {
            if let identifier = managedObject.valueForKey("identifier") as? String {
                (courseObject, examObject, scoreObject) = MobileManager.sharedInstance.objectTripleWithIdentifier(identifier)
                courseEvent = EventManager.sharedInstance.courseEventForIdentifier(identifier)
            }
        }
    }
    
    var courseObject: Course?
    var examObject: Exam?
    var scoreObject: Score?
    var courseEvent: CourseEvent!
    
    var homeworks = [Homework]()
    var selectedHomework: Homework?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = courseObject!.name
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(edit))
        tableView.registerNib(UINib(nibName: "HomeworkCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Homework")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if managedObject.managedObjectContext == nil {
            navigationController?.popViewControllerAnimated(false)
        } else {
            reloadData()
        }
    }
    
    func reloadData() {
        homeworks = courseEvent.homeworks!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "deadline", ascending: false)]) as! [Homework]
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nc = segue.destinationViewController as! UINavigationController
        switch segue.identifier! {
        case "Edit":
            let vc = nc.topViewController as! CourseEditViewController
            vc.courseEvent = courseEvent
        case "Homework":
            let vc = nc.topViewController as! HomeworkViewController
            if let hw = selectedHomework {
                vc.homework = hw
            } else {
                vc.homework = EventManager.sharedInstance.newHomeworkOfCourseEvent(courseEvent)
            }
        default:
            break
        }
    }
    
    private enum Detail: Int {
        case Basic = 0, Exam, Info, Homework, Notes
        static let count = 5
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
            "title": "助教",
            "key": "ta",
        ],
        [
            "title": "助教邮箱",
            "key": "taEmail",
        ],
        [
            "title": "助教电话",
            "key": "taPhone",
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
        switch Detail(rawValue: section)! {
        case .Basic:
            return courseObject!.timePlaces!.count + 1
        case .Exam:
            return 2
        case .Info:
            var count = 0
            for info in infos {
                if let value = courseEvent.valueForKey(info["key"]!) as? String {
                    if !value.isEmpty {
                        count += 1
                    }
                }
            }
            return count
        case .Homework:
            return homeworks.count + 1
        case .Notes:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch Detail(rawValue: indexPath.section)! {
        case .Basic:
            switch indexPath.row {
            case 0:
                return 66
            default:
                return 60
            }
        case .Exam:
            if indexPath.row == 1 && examObject?.startTime != nil {
                return 60
            } else {
                return 44
            }
        case .Homework:
            if indexPath.row == 0 {
                return 44
            } else {
                return 60
            }
        case .Notes:
            return 150
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Detail.Notes.rawValue {
            return "备注"
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch Detail(rawValue: indexPath.section)! {
        case .Basic:
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
                cell.timeLabel!.text = courseObject!.semester! + "学期 " + timePlace.time!
                return cell
            }
        case .Exam:
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
        case .Info:
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
        case .Homework:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.textLabel!.text = "添加新的作业…"
                cell.detailTextLabel!.text = ""
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("Homework") as! HomeworkCell
                let hw = homeworks[indexPath.row - 1]
                cell.nameLabel.text = hw.name
                cell.timeLabel.text = hw.deadline?.stringOfDatetime
                cell.courseLabel.removeFromSuperview()
                return cell
            }
        case .Notes:
            let cell = tableView.dequeueReusableCellWithIdentifier("Notes") as! CourseNotesCell
            cell.notesTextView.text = courseEvent.notes
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch Detail(rawValue: indexPath.section)! {
        case .Info:
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            switch cell.textLabel!.text! {
            case "教师":
                let url = NSURL(string: "http://chalaoshi.cn/search?q=" + cell.detailTextLabel!.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(URL: url)
                    presentViewController(svc, animated: true, completion: nil)
                }
            case "电子邮箱", "助教邮箱":
                if MFMailComposeViewController.canSendMail() {
                    let mcvc = MFMailComposeViewController()
                    mcvc.mailComposeDelegate = self
                    mcvc.setToRecipients([cell.detailTextLabel!.text!])
                    presentViewController(mcvc, animated: true, completion: nil)
                } else {
                    let pasteboard = UIPasteboard.generalPasteboard()
                    pasteboard.string = cell.detailTextLabel!.text
                    SVProgressHUD.showSuccessWithStatus("已拷贝到剪贴板")
                }
            case "联系电话", "助教电话":
                UIApplication.sharedApplication().openURL(NSURL(string: "telprompt:" + cell.detailTextLabel!.text!)!)
            case "课程网站":
                var prefix = ""
                if !cell.detailTextLabel!.text!.containsString("://") {
                    prefix = "http://"
                } else if !cell.detailTextLabel!.text!.hasPrefix("http") {
                    prefix = "不支持 "
                }
                if let url = NSURL(string: prefix + cell.detailTextLabel!.text!) {
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
        case .Homework:
            if indexPath.row == 0 {
                selectedHomework = nil
            } else {
                selectedHomework = homeworks[indexPath.row - 1]
            }
            performSegueWithIdentifier("Homework", sender: nil)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == Detail.Homework.rawValue && indexPath.row < homeworks.count {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "删除") { action, indexPath in
            EventManager.sharedInstance.removeHomework(self.homeworks[indexPath.row])
            self.reloadData()
        }
        return [delete]
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
