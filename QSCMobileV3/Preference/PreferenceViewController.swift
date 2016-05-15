//
//  PreferenceViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-04.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import MessageUI
import QSCMobileKit

let RefreshOnLaunchKey = "RefreshOnLaunch"

class PreferenceViewController: UITableViewController {
    
    private let accountManager = AccountManager.sharedInstance
    private let mobileManager = MobileManager.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    private enum Preference: Int {
        case Jwbinfosys = 0, Zjuwlan, Setting, About
        static let count = 4
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Preference.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Preference.Jwbinfosys.rawValue:
            return "教务网"
        case Preference.Zjuwlan.rawValue:
            return "ZJUWLAN"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case Preference.About.rawValue:
            return "Copyright © 2016 QSC Tech."
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Preference.Jwbinfosys.rawValue:
            return accountManager.allAccountsForJwbinfosys.count + 1
        case Preference.Zjuwlan.rawValue:
            return 1
        case Preference.Setting.rawValue:
            return 2
        case Preference.About.rawValue:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Preference.Jwbinfosys.rawValue:
            let accounts = accountManager.allAccountsForJwbinfosys
            if indexPath.row < accounts.count {
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
                let account = accounts[indexPath.row]
                cell.textLabel!.attributedText = "\u{f007}\t\(account)".attributedWithFontAwesome
                if account == accountManager.currentAccountForJwbinfosys {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
                cell.textLabel!.attributedText = "\u{f234}\t添加用户".attributedWithFontAwesome
                return cell
            }
        case Preference.Zjuwlan.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
            cell.textLabel!.attributedText = "\u{f1eb}\t\(accountManager.accountForZjuwlan ?? "未设置账号")".attributedWithFontAwesome
            return cell
        case Preference.Setting.rawValue:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
                cell.textLabel!.attributedText = "\u{f021}\t启动时自动刷新".attributedWithFontAwesome
                // TODO: Change tint color (TBD)
                let switchView = UISwitch(frame: CGRectZero)
                let refreshOnLaunch = groupDefaults.objectForKey(RefreshOnLaunchKey) as! Bool
                switchView.setOn(refreshOnLaunch, animated: false)
                switchView.addTarget(self, action: #selector(refreshSwitchChanged), forControlEvents: .ValueChanged)
                cell.accessoryView = switchView
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("Detail")!
                cell.textLabel!.attributedText = "\u{f073}\t日程提醒".attributedWithFontAwesome
                cell.detailTextLabel!.text = EventNotificationViewController.status
                return cell
            default:
                return UITableViewCell()
            }
        case Preference.About.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "关于我们"
            case 1:
                cell.textLabel!.text = "用户反馈"
            case 2:
                cell.textLabel!.text = "去评分"
            default:
                return UITableViewCell()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case Preference.Jwbinfosys.rawValue:
            let accounts = accountManager.allAccountsForJwbinfosys
            if indexPath.row < accounts.count {
                for row in 0...(tableView.numberOfRowsInSection(indexPath.section) - 2) {
                    let indexPath = NSIndexPath(forRow: row, inSection: indexPath.section)
                    tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .None
                }
                tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .Checkmark
                mobileManager.changeUser(accounts[indexPath.row])
            } else {
                performSegueWithIdentifier("showLogin", sender: nil)
            }
        case Preference.Zjuwlan.rawValue:
            performSegueWithIdentifier("showZjuwlan", sender: nil)
        case Preference.Setting.rawValue:
            switch indexPath.row {
            case 1:
                performSegueWithIdentifier("showEventNotification", sender: nil)
            default:
                break
            }
        case Preference.About.rawValue:
            switch indexPath.row {
            case 0:
                let wvc = WebViewController(url: nil, title: "关于我们")
                showViewController(wvc, sender: nil)
            case 1:
                if MFMailComposeViewController.canSendMail() {
                    let mcvc = MFMailComposeViewController()
                    mcvc.mailComposeDelegate = self
                    mcvc.setToRecipients(["mobile@zjuqsc.com"])
                    mcvc.setSubject("[QSCMobileV3] Feedback")
                    mcvc.setMessageBody("版本信息：\nQSCMobile Version \(QSCVersion)\niOS \(NSProcessInfo.processInfo().operatingSystemVersionString)\n\n反馈：\n\u{200b}", isHTML: false)
                    presentViewController(mcvc, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "用户反馈", message: "您尚未设置系统邮件账户，请先行设置或直接发送邮件至 mobile@zjuqsc.com", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "好", style: .Default, handler: nil)
                    alert.addAction(action)
                    presentViewController(alert, animated: true, completion: nil)
                }
            case 2:
                let appLink = "https://itunes.apple.com/cn/app/qiu-shi-chao-mobile/id583334920"
                UIApplication.sharedApplication().openURL(NSURL(string: appLink)!)
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == Preference.Jwbinfosys.rawValue && indexPath.row < accountManager.allAccountsForJwbinfosys.count {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "注销") { action, indexPath in
            let account = self.accountManager.allAccountsForJwbinfosys[indexPath.row]
            if account == self.accountManager.currentAccountForJwbinfosys && tableView.numberOfRowsInSection(indexPath.section) > 1 {
                let indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
                let cell = tableView.cellForRowAtIndexPath(indexPath)!
                cell.accessoryType = .Checkmark
            }
            self.mobileManager.deleteUser(account)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        return [delete]
    }
    
    func refreshSwitchChanged(sender: AnyObject) {
        let switchView = sender as! UISwitch
        groupDefaults.setObject(switchView.on, forKey: RefreshOnLaunchKey)
    }
    
}

extension PreferenceViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        if result == MFMailComposeResultSent {
            let alert = UIAlertController(title: "用户反馈", message: "感谢您的反馈！\n我们将在一周内回复您的邮件", preferredStyle: .Alert)
            let action = UIAlertAction(title: "好", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}