//
//  PreferenceViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-04.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class PreferenceViewController: UITableViewController {
    
    private let accountManager = AccountManager.sharedInstance
    private let mobileManager = MobileManager.sharedInstance
    
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
            return 1
        case Preference.About.rawValue:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        switch indexPath.section {
        case Preference.Jwbinfosys.rawValue:
            let accounts = accountManager.allAccountsForJwbinfosys
            if indexPath.row < accounts.count {
                let account = accounts[indexPath.row]
                cell.textLabel!.attributedText = "\u{f007}\t\(account)".attributedWithFontAwesome
                if account == accountManager.currentAccountForJwbinfosys {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            } else {
                cell.textLabel!.attributedText = "\u{f234}\t添加用户".attributedWithFontAwesome
            }
        case Preference.Zjuwlan.rawValue:
            cell.textLabel!.attributedText = "\u{f1eb}\t\(accountManager.accountForZjuwlan ?? "账号设置")".attributedWithFontAwesome
        case Preference.Setting.rawValue:
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "日程提醒"
                let switchView = UISwitch(frame: CGRectZero)
                switchView.setOn(true, animated: false)
                cell.accessoryView = switchView
            default:
                break
            }
        case Preference.About.rawValue:
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "关于我们"
            case 1:
                cell.textLabel!.text = "用户反馈"
            case 2:
                cell.textLabel!.text = "去评分"
            default:
                break
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case Preference.Jwbinfosys.rawValue:
            let accounts = accountManager.allAccountsForJwbinfosys
            if indexPath.row < accounts.count {
                mobileManager.changeUser(accounts[indexPath.row])
                tableView.reloadData()
            } else {
                performSegueWithIdentifier("showLogin", sender: nil)
            }
        case Preference.Zjuwlan.rawValue:
            performSegueWithIdentifier("showZjuwlan", sender: nil)
        case Preference.Setting.rawValue:
            switch indexPath.row {
            default:
                break
            }
        case Preference.About.rawValue:
            switch indexPath.row {
            case 0:
                let wvc = WebViewController(url: nil, title: "关于我们")
                showViewController(wvc, sender: nil)
            case 1:
                let mailBody = "版本信息：\nQSCMobile Version \(QSCVersion)\niOS \(NSProcessInfo.processInfo().operatingSystemVersionString)\n\n反馈：".percentEncoded
                let mailLink = "mailto:mobile@zjuqsc.com?subject=%5BQSCMobileV3%5D%20Feedback&body=\(mailBody)"
                UIApplication.sharedApplication().openURL(NSURL(string: mailLink)!)
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
            tableView.reloadData()
        }
        return [delete]
    }
    
}
