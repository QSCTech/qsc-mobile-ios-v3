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
    
    let accountManager = AccountManager.sharedInstance
    let mobileManager = MobileManager.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    enum Preference: Int {
        case jwbinfosys = 0, zjuwlan, setting, about
        static let count = 4
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Preference.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Preference(rawValue: section)! {
        case .jwbinfosys:
            return "教务网"
        case .zjuwlan:
            return "ZJUWLAN"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Preference(rawValue: section)! {
        case .about:
            return "Copyright © 2016 QSC Tech."
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Preference(rawValue: section)! {
        case .jwbinfosys:
            return accountManager.allAccountsForJwbinfosys.count + 1
        case .zjuwlan:
            return accountManager.accountForZjuwlan == nil ? 1 : 2
        case .setting:
            return 2
        case .about:
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Preference(rawValue: indexPath.section)! {
        case .jwbinfosys:
            let accounts = accountManager.allAccountsForJwbinfosys
            if indexPath.row < accounts.count {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.tintColor = QSCColor.theme
                let account = accounts[indexPath.row]
                cell.textLabel!.attributedText = "\u{f007}\t\(account)".attributedWithFontAwesome
                if account == accountManager.currentAccountForJwbinfosys {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
                cell.textLabel!.attributedText = "\u{f234}\t添加用户".attributedWithFontAwesome
                return cell
            }
        case .zjuwlan:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
                cell.textLabel!.attributedText = "\u{f1eb}\t\(accountManager.accountForZjuwlan ?? "未设置账号")".attributedWithFontAwesome
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel!.attributedText = "\u{f0ec}\t一键连接".attributedWithFontAwesome
                return cell
            }
        case .setting:
            switch indexPath.row {
            case 0:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.textLabel!.attributedText = "\u{f021}\t启动时自动刷新".attributedWithFontAwesome
                let switchView = UISwitch()
                switchView.isOn = groupDefaults.bool(forKey: RefreshOnLaunchKey)
                switchView.onTintColor = QSCColor.theme
                switchView.addTarget(self, action: #selector(refreshSwitchChanged), for: .valueChanged)
                cell.accessoryView = switchView
                return cell
            case 1:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.textLabel!.attributedText = "\u{f06e}\t在课程和工具页面显示成绩".attributedWithFontAwesome
                let switchView = UISwitch()
                switchView.isOn = groupDefaults.bool(forKey: ShowScoreKey)
                switchView.onTintColor = QSCColor.theme
                switchView.addTarget(self, action: #selector(showScoreSwitchChanged), for: .valueChanged)
                cell.accessoryView = switchView
                return cell
            default:
                return UITableViewCell()
            }
        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
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
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Preference(rawValue: indexPath.section)! {
        case .jwbinfosys:
            let accounts = accountManager.allAccountsForJwbinfosys
            if indexPath.row < accounts.count {
                mobileManager.changeUser(accounts[indexPath.row])
                reloadRowsOfJwbinfosys()
            } else {
                let vc = JwbinfosysLoginViewController()
                present(vc, animated: true)
            }
        case .zjuwlan:
            if indexPath.row == 0{
                let vc = ZjuwlanLoginViewController()
                show(vc, sender: nil)
            } else {
                SVProgressHUD.show(withStatus: "连接中")
                ZjuwlanConnection.link { success, error in
                    if success {
                        SVProgressHUD.showSuccess(withStatus: "连接成功")
                    } else {
                        SVProgressHUD.showError(withStatus: error!)
                    }
                }
            }
        case .about:
            switch indexPath.row {
            case 0:
                let vc = AboutViewController()
                vc.hidesBottomBarWhenPushed = true
                show(vc, sender: nil)
            case 1:
                if MFMailComposeViewController.canSendMail() {
                    let mcvc = MFMailComposeViewController()
                    mcvc.mailComposeDelegate = self
                    mcvc.setToRecipients(["mobile@zjuqsc.com"])
                    mcvc.setSubject("[QSCMobileV3] Feedback")
                    var deviceInfo = ""
                    if let deviceToken = groupDefaults.string(forKey: DeviceTokenKey) {
                        deviceInfo = "Device Token: \(deviceToken)\n"
                    }
                    mcvc.setMessageBody("版本信息：\nQSCMobile \(QSCVersion)\n\(Device()) \(ProcessInfo.processInfo.operatingSystemVersionString)\n\(deviceInfo)\n反馈（可附截屏）：\n\u{200b}", isHTML: false)
                    present(mcvc, animated: true)
                } else {
                    let alert = UIAlertController(title: "用户反馈", message: "您尚未设置系统邮件账户，请先行设置或直接发送邮件至 mobile@zjuqsc.com", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alert.addAction(action)
                    present(alert, animated: true)
                }
            case 2:
                let appLink = "https://itunes.apple.com/cn/app/id583334920"
                UIApplication.shared.openURL(URL(string: appLink)!)
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Preference.jwbinfosys.rawValue && indexPath.row < accountManager.allAccountsForJwbinfosys.count {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "注销") { action, indexPath in
            let account = self.accountManager.allAccountsForJwbinfosys[indexPath.row]
            self.mobileManager.deleteUser(account)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.reloadRowsOfJwbinfosys()
        }
        return [delete]
    }
    
    func refreshSwitchChanged(_ sender: AnyObject) {
        let switchView = sender as! UISwitch
        groupDefaults.set(switchView.isOn, forKey: RefreshOnLaunchKey)
    }
    
    func showScoreSwitchChanged(_ sender: AnyObject) {
        let switchView = sender as! UISwitch
        groupDefaults.set(switchView.isOn, forKey: ShowScoreKey)
    }
    
    func reloadRowsOfJwbinfosys() {
        if accountManager.currentAccountForJwbinfosys == nil {
            return
        }
        var indexPaths = [IndexPath]()
        for row in 0...(tableView.numberOfRows(inSection: Preference.jwbinfosys.rawValue) - 2) {
            indexPaths.append(IndexPath(row: row, section: Preference.jwbinfosys.rawValue))
        }
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
}

extension PreferenceViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if result == .sent {
            let alert = UIAlertController(title: "用户反馈", message: "感谢您的反馈！\n我们将尽快回复您的邮件", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
}
