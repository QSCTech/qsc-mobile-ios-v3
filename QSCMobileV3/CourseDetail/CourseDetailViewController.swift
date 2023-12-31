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

class CourseDetailViewController: UITableViewController, CourseEditViewControllerDelegate, HomeworkViewControllerDelegate {
    
    var managedObject: NSManagedObject!
    var courseObject: Course?
    var examObject: Exam?
    var scoreObject: Score?
    var courseEvent: CourseEvent!
    
    var homeworks = [Homework]()
    var selectedHomework: Homework?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let identifier = managedObject.value(forKey: "identifier") as? String else { return }
        let mobileManager = MobileManager.sharedInstance
        courseObject = mobileManager.courseObjectsWithIdentifier(identifier).first
        examObject = mobileManager.examObjectsWithIdentifier(identifier).filter({ !$0.name!.contains("补考") && !$0.name!.contains("期中") }).first
        scoreObject = mobileManager.scoreObjectsWithIdentifier(identifier).filter({ !$0.name!.contains("补考") }).first
        courseEvent = EventManager.sharedInstance.courseEventForIdentifier(identifier)
        navigationItem.title = courseObject?.name ?? ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        tableView.register(UINib(nibName: "HomeworkCell", bundle: Bundle.main), forCellReuseIdentifier: "Homework")
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear), name: .refreshCompleted, object: nil)
        tableView.backgroundColor = UIColor.groupTableViewBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if managedObject.managedObjectContext == nil || courseObject == nil {
            _ = navigationController?.popViewController(animated: true)
        } else {
            reloadData()
        }
    }
    
    func refresh() {
        self.viewWillAppear(true)
    }
    
    func reloadData() {
        homeworks = courseEvent.homeworks!.sortedArray(using: [NSSortDescriptor(key: "deadline", ascending: false)]) as! [Homework]
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = segue.destination as! UINavigationController
        switch segue.identifier! {
        case "Edit":
            let vc = nc.topViewController as! CourseEditViewController
            vc.courseEvent = courseEvent
            vc.delegate = self
        case "Homework":
            let vc = nc.topViewController as! HomeworkViewController
            vc.delegate = self
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
        case basic = 0, exam, info, homework, notes
        static let count = 5
    }
    
    let infos = [
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
        guard let courseObject = courseObject else {
            return 0
        }
        
        switch Detail(rawValue: section)! {
        case .basic:
            return courseObject.timePlaces!.count + 1
        case .exam:
            return 3
        case .info:
            var count = 0
            for info in infos {
                if let value = courseEvent.value(forKey: info["key"]!) as? String {
                    if !value.isEmpty {
                        count += 1
                    }
                }
            }
            return count
        case .homework:
            return homeworks.count + 1
        case .notes:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Detail(rawValue: indexPath.section)! {
        case .basic:
            switch indexPath.row {
            case 0:
                return 66
            default:
                return 60
            }
        case .exam:
            if indexPath.row == 2 && examObject?.startTime != nil {
                return 60
            } else {
                return 44
            }
        case .homework:
            if indexPath.row == 0 {
                return 44
            } else {
                return 60
            }
        case .notes:
            return 150
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Detail.notes.rawValue && courseObject != nil {
            return "备注"
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let courseObject = courseObject else {
            return UITableViewCell()
        }
        
        switch Detail(rawValue: indexPath.section)! {
        case .basic:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Name") as! CourseNameCell
                cell.nameLabel.text = courseObject.name
                cell.identifierLabel!.text = courseObject.identifier
                cell.categoryLabel!.text = courseObject.category
                if managedObject as? Course != nil {
                    cell.dotView.backgroundColor = QSCColor.course
                } else if managedObject as? Exam != nil {
                    cell.dotView.backgroundColor = QSCColor.exam
                }
                cell.nameLabel.textColor = ColorCompatibility.label
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimePlace") as! CourseTimePlaceCell
                let sortDescriptors = [NSSortDescriptor(key: "weekday", ascending: true), NSSortDescriptor(key: "periods", ascending: true)]
                let timePlace = courseObject.timePlaces!.sortedArray(using: sortDescriptors)[indexPath.row - 1] as! TimePlace
                cell.placeLabel!.text = timePlace.place!
                cell.timeLabel!.text = courseObject.semester! + "学期 " + timePlace.time!
                return cell
            }
        case .exam:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel!.text = "教师"
                cell.detailTextLabel!.text = courseObject.teacher
                cell.textLabel!.textColor = ColorCompatibility.label
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.selectionStyle = .none
                var credit = courseObject.credit!.floatValue
                if credit == 0 {
                    credit = examObject?.credit?.floatValue ?? 0
                }
                if credit == 0 {
                    credit = scoreObject?.credit?.floatValue ?? 0
                }
                cell.textLabel!.text = "学分：\(credit)"
                if let scoreObject = scoreObject {
                    cell.detailTextLabel!.text =  String(format: "成绩：%.1f / %@", scoreObject.gradePoint!.floatValue, scoreObject.score!)
                } else {
                    cell.detailTextLabel!.text = "暂无成绩信息"
                }
                if !groupDefaults.bool(forKey: ShowScoreKey) {
                    cell.detailTextLabel!.text = ""
                }
                cell.textLabel!.textColor = ColorCompatibility.label
                return cell
            default:
                if let examObject = examObject, examObject.startTime != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TimePlace") as! CourseTimePlaceCell
                    cell.placeLabel!.text = examObject.place
                    if !examObject.seat!.isEmpty {
                        cell.placeLabel!.text! += " #" + examObject.seat!
                    }
                    cell.timeLabel!.text = examObject.time
                    cell.textLabel!.textColor = ColorCompatibility.label
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                    cell.selectionStyle = .none
                    cell.textLabel!.text = "无考试信息"
                    cell.detailTextLabel!.text = ""
                    cell.textLabel!.textColor = ColorCompatibility.label
                    return cell
                }
            }
        case .info:
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
        case .homework:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Detail")!
                cell.textLabel!.text = "添加新的作业…"
                cell.detailTextLabel!.text = ""
                cell.textLabel!.textColor = ColorCompatibility.label
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Homework") as! HomeworkCell
                let hw = homeworks[indexPath.row - 1]
                if hw.isFinished!.boolValue {
                    cell.dotView.isHidden = true
                    cell.nameLabel.attributedText = NSAttributedString(string: hw.name!, attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
                } else {
                    cell.dotView.isHidden = false
                    cell.nameLabel.text = hw.name
                }
                cell.timeLabel.text = hw.deadline?.stringOfDatetime
                cell.courseLabel.removeFromSuperview()
                cell.nameLabel.textColor = ColorCompatibility.label
                return cell
            }
        case .notes:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Notes") as! CourseNotesCell
            cell.notesTextView.text = courseEvent.notes
            cell.notesTextView.backgroundColor = cell.contentView.backgroundColor
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        switch Detail(rawValue: indexPath.section)! {
        case .exam:
            if indexPath.row != 0 {
                break
            }
            let urlString = "https://enroll.zjuqsc.com/search?q="
            let handler = { (action: UIAlertAction) in
                let url = URL(string: urlString + action.title!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true)
            }
            let teachers = cell.detailTextLabel!.text!.components(separatedBy: " ")
            if teachers.count > 1 {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                for teacher in teachers {
                    let action = UIAlertAction(title: teacher, style: .default, handler: handler)
                    alert.addAction(action)
                }
                alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                present(alert, animated: true)
            } else if teachers.count == 1 {
                let action = UIAlertAction(title: teachers.first, style: .default, handler: handler)
                handler(action)
            }
        case .info:
            switch cell.textLabel!.text! {
            case "电子邮箱", "助教邮箱":
                if MFMailComposeViewController.canSendMail() {
                    let mcvc = MFMailComposeViewController()
                    mcvc.mailComposeDelegate = self
                    mcvc.setToRecipients([cell.detailTextLabel!.text!])
                    present(mcvc, animated: true)
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
                    present(svc, animated: true)
                } else {
                    let alert = UIAlertController(title: "课程网站", message: "浏览器无法打开链接", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default)
                    alert.addAction(action)
                    present(alert, animated: true)
                }
            default:
                UIPasteboard.general.string = cell.detailTextLabel!.text
                SVProgressHUD.showSuccess(withStatus: "已拷贝到剪贴板")
            }
        case .homework:
            if indexPath.row == 0 {
                selectedHomework = nil
            } else {
                selectedHomework = homeworks[indexPath.row - 1]
            }
            performSegue(withIdentifier: "Homework", sender: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Detail.homework.rawValue && indexPath.row > 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { action, indexPath in
            EventManager.sharedInstance.removeHomework(self.homeworks[indexPath.row - 1])
            self.reloadData()
        }
        return [delete]
    }
    
    @objc func edit(_ sender: AnyObject) {
        performSegue(withIdentifier: "Edit", sender: nil)
    }
    
}

extension CourseDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
