//
//  PreferenceViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-04.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import MessageUI
import SVProgressHUD
import DeviceKit
import QSCMobileKit

let RefreshOnLaunchKey = "RefreshOnLaunch"
let ShowScoreKey = "ShowScore"
let DeviceTokenKey = "DeviceToken"

class PreferenceViewController: UITableViewController {
    
    private let accountManager = AccountManager.sharedInstance
    private let mobileManager = MobileManager.sharedInstance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
            return accountManager.accountForZjuwlan == nil ? 1 : 2
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
                cell.tintColor = QSCColor.theme
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
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
                cell.textLabel!.attributedText = "\u{f1eb}\t\(accountManager.accountForZjuwlan ?? "未设置账号")".attributedWithFontAwesome
                return cell
            } else {
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
                cell.textLabel!.attributedText = "\u{f0ec}\t一键连接".attributedWithFontAwesome
                return cell
            }
        case Preference.Setting.rawValue:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
                cell.selectionStyle = .None
                cell.textLabel!.attributedText = "\u{f021}\t启动时自动刷新".attributedWithFontAwesome
                let switchView = UISwitch()
                switchView.on = groupDefaults.boolForKey(RefreshOnLaunchKey)
                switchView.onTintColor = QSCColor.theme
                switchView.addTarget(self, action: #selector(refreshSwitchChanged), forControlEvents: .ValueChanged)
                cell.accessoryView = switchView
                return cell
            case 1:
                let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
                cell.selectionStyle = .None
                cell.textLabel!.attributedText = "\u{f06e}\t在课程和工具页面显示成绩".attributedWithFontAwesome
                let switchView = UISwitch()
                switchView.on = groupDefaults.boolForKey(ShowScoreKey)
                switchView.onTintColor = QSCColor.theme
                switchView.addTarget(self, action: #selector(showScoreSwitchChanged), forControlEvents: .ValueChanged)
                cell.accessoryView = switchView
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
                mobileManager.changeUser(accounts[indexPath.row])
                reloadRowsOfJwbinfosys()
            } else {
                let vc = JwbinfosysLoginViewController()
                presentViewController(vc, animated: true, completion: nil)
            }
        case Preference.Zjuwlan.rawValue:
            if indexPath.row == 0{
                let vc = ZjuwlanLoginViewController()
                showViewController(vc, sender: nil)
            } else {
                ZjuwlanConnection.link { success, error in
                    if success {
                        SVProgressHUD.showSuccessWithStatus("连接成功")
                    } else {
                        SVProgressHUD.showErrorWithStatus(error!)
                    }
                }
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
                    var deviceInfo = ""
                    if let deviceToken = groupDefaults.stringForKey(DeviceTokenKey) {
                        deviceInfo = "Device Token: \(deviceToken)\n"
                    }
                    mcvc.setMessageBody("版本信息：\nQSCMobile Version \(QSCVersion)\n\(Device()) \(NSProcessInfo.processInfo().operatingSystemVersionString)\n\(deviceInfo)\n反馈（可附截屏）：\n\u{200b}", isHTML: false)
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
            self.mobileManager.deleteUser(account)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.reloadRowsOfJwbinfosys()
        }
        return [delete]
    }
    
    func refreshSwitchChanged(sender: AnyObject) {
        let switchView = sender as! UISwitch
        groupDefaults.setBool(switchView.on, forKey: RefreshOnLaunchKey)
    }
    
    func showScoreSwitchChanged(sender: AnyObject) {
        let switchView = sender as! UISwitch
        groupDefaults.setBool(switchView.on, forKey: ShowScoreKey)
    }
    
    private func reloadRowsOfJwbinfosys() {
        if accountManager.currentAccountForJwbinfosys == nil {
            return
        }
        var indexPaths = [NSIndexPath]()
        for row in 0...(tableView.numberOfRowsInSection(Preference.Jwbinfosys.rawValue) - 2) {
            indexPaths.append(NSIndexPath(forRow: row, inSection: Preference.Jwbinfosys.rawValue))
        }
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
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
