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
            if let identifier = managedObject.value(forKey: "identifier") as? String {
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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        tableView.register(UINib(nibName: "HomeworkCell", bundle: Bundle.main), forCellReuseIdentifier: "Homework")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if managedObject.managedObjectContext == nil {
            _ = navigationController?.popViewController(animated: false)
        } else {
            reloadData()
        }
    }
    
    func reloadData() {
        homeworks = courseEvent.homeworks!.sortedArray(using: [NSSortDescriptor(key: "deadline", ascending: true)]) as! [Homework]
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = segue.destination as! UINavigationController
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
    
    enum Detail: Int {
        case basic = 0, exam, info, notes, homework
        static let count = 5
    }
    
    let infos = [
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Detail.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Detail.basic.rawValue:
            return courseObject!.timePlaces!.count + 1
        case Detail.exam.rawValue:
            return 2
        case Detail.info.rawValue:
            var count = 0
            for info in infos {
                if let value = courseEvent.value(forKey: info["key"]!) as? String {
                    if !value.isEmpty {
                        count += 1
                    }
                }
            }
            return count
        case Detail.notes.rawValue:
            return 1
        case Detail.homework.rawValue:
            return homeworks.count + 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Detail.basic.rawValue:
            switch indexPath.row {
            case 0:
                return 66
            default:
                return 60
            }
        case Detail.exam.rawValue:
            if indexPath.row == 1 && examObject?.startTime != nil {
                return 60
            } else {
                return 44
            }
        case Detail.notes.rawValue:
            return 150
        case Detail.homework.rawValue:
            if indexPath.row < homeworks.count {
                return 60
            } else {
                return 44
            }
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Detail.notes.rawValue {
            return "备注"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Detail.basic.rawValue:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Name") as! CourseNameCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimePlace") as! CourseTimePlaceCell
                let sortDescriptors = [NSSortDescriptor(key: "weekday", ascending: true), NSSortDescriptor(key: "periods", ascending: true)]
                let timePlace = courseObject!.timePlaces!.sortedArray(using: sortDescriptors)[indexPath.row - 1] as! TimePlace
                cell.placeLabel!.text = timePlace.place!
                cell.timeLabel!.text = courseObject!.semester! + "学期 " + timePlace.time!
                return cell
            }
        case Detail.exam.rawValue:
            switch indexPath.row {
            case 1:
                if let examObject = examObject, let _ = examObject.startTime {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TimePlace") as! CourseTimePlaceCell
                    cell.placeLabel!.text = examObject.place
                    if !examObject.seat!.isEmpty {
                        cell.placeLabel!.text! += " #" + examObject.seat!
                    }
                    cell.timeLabel!.text = examObject.time
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                    cell.selectionStyle = .none
                    cell.textLabel!.text = "无考试信息"
                    cell.detailTextLabel!.text = ""
                    return cell
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.selectionStyle = .none
                cell.textLabel!.text = "学分：" + courseObject!.credit!.stringValue
                if let scoreObject = scoreObject {
                    cell.detailTextLabel!.text =  String(format: "成绩：%.1f / %@", scoreObject.gradePoint!.floatValue, scoreObject.score!)
                } else {
                    cell.detailTextLabel!.text = "暂无成绩信息"
                }
                if !groupDefaults.bool(forKey: ShowScoreKey) {
                    cell.detailTextLabel!.text = ""
                }
                return cell
            }
        case Detail.info.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
            var values = [(String, String)]()
            for info in infos {
                if let value = courseEvent.value(forKey: info["key"]!) as? String {
                    if !value.isEmpty {
                        values.append((info["title"]!, value))
                    }
                }
            }
            cell.textLabel!.text = values[indexPath.row].0
            cell.detailTextLabel!.text = values[indexPath.row].1
            return cell
        case Detail.notes.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Notes") as! CourseNotesCell
            cell.notesTextView.text = courseEvent.notes
            return cell
        case Detail.homework.rawValue:
            if indexPath.row < homeworks.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Homework") as! HomeworkCell
                cell.nameLabel.text = homeworks[indexPath.row].name
                cell.timeLabel.text = homeworks[indexPath.row].deadline?.stringOfDatetime
                cell.courseLabel.removeFromSuperview()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel!.text = "添加新的作业…"
                cell.detailTextLabel!.text = ""
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case Detail.info.rawValue:
            let cell = tableView.cellForRow(at: indexPath)!
            switch cell.textLabel!.text! {
            case "教师":
                let url = URL(string: "http://chalaoshi.cn/search?q=" + cell.detailTextLabel!.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
                let svc = SFSafariViewController(url: url)
                present(svc, animated: true, completion: nil)
            case "电子邮箱", "助教邮箱":
                if MFMailComposeViewController.canSendMail() {
                    let mcvc = MFMailComposeViewController()
                    mcvc.mailComposeDelegate = self
                    mcvc.setToRecipients([cell.detailTextLabel!.text!])
                    present(mcvc, animated: true, completion: nil)
                } else {
                    UIPasteboard.general.string = cell.detailTextLabel!.text
                    SVProgressHUD.showSuccess(withStatus: "已拷贝到剪贴板")
                }
            case "联系电话", "助教电话":
                UIApplication.shared.openURL(URL(string: "telprompt:" + cell.detailTextLabel!.text!)!)
            case "课程网站":
                var prefix = ""
                if !cell.detailTextLabel!.text!.contains("://") {
                    prefix = "http://"
                } else if !cell.detailTextLabel!.text!.hasPrefix("http") {
                    prefix = "不支持 "
                }
                if let url = URL(string: prefix + cell.detailTextLabel!.text!) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "课程网站", message: "浏览器无法打开链接", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                }
            default:
                UIPasteboard.general.string = cell.detailTextLabel!.text
                SVProgressHUD.showSuccess(withStatus: "已拷贝到剪贴板")
            }
        case Detail.homework.rawValue:
            if indexPath.row < homeworks.count {
                selectedHomework = homeworks[indexPath.row]
            } else {
                selectedHomework = nil
            }
            performSegue(withIdentifier: "Homework", sender: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Detail.homework.rawValue && indexPath.row < homeworks.count {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { action, indexPath in
            EventManager.sharedInstance.removeHomework(self.homeworks[indexPath.row])
            self.reloadData()
        }
        return [delete]
    }
    
    func edit(_ sender: AnyObject) {
        performSegue(withIdentifier: "Edit", sender: nil)
    }
    
}

extension CourseDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
