//
//  PreferenceViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-04.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit
import SVProgressHUD
import DeviceKit
import QSCMobileKit

let RefreshOnLaunchKey = "RefreshOnLaunch"
let LastRefreshDateKey = "LastRefreshDate"
let ShowScoreKey = "ShowScore"
let AuxiliaryScoreKey = "AuxiliaryScore"
let DeviceTokenKey = "DeviceToken"

class PreferenceViewController: UITableViewController, JwbLoginViewControllerDelegate {
    
    let accountManager = AccountManager.sharedInstance
    let mobileManager = MobileManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.backgroundColor = UIColor.groupTableViewBackground
        //navigationController?.navigationBar.barTintColor = ColorCompatibility.systemGray6
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func refresh() {
        self.viewWillAppear(true)
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
            return "Copyright © 2016-2019 QSC Tech."
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
            return groupDefaults.bool(forKey: ShowScoreKey) ? 3 : 2
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
                cell.textLabel!.textColor = ColorCompatibility.label
                
                return cell
            }
        case .zjuwlan:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
                cell.textLabel!.attributedText = "\u{f1eb}\t\(accountManager.accountForZjuwlan ?? "未设置账号")".attributedWithFontAwesome
                
                if #available(iOS 13, *) {
                    cell.textLabel!.textColor = UIColor.label
                }
                
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
                cell.textLabel!.attributedText = "\u{f021}\t每天自动刷新数据".attributedWithFontAwesome
                let switchView = UISwitch()
                switchView.isOn = groupDefaults.bool(forKey: RefreshOnLaunchKey)
                switchView.onTintColor = QSCColor.theme
                switchView.addTarget(self, action: #selector(refreshSwitchChanged), for: .valueChanged)
                cell.accessoryView = switchView
                return cell
            case 1:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.textLabel!.attributedText = "\u{f06e}\t在课程和工具页面显示成绩".attributedWithFontAwesome
                let switchView = UISwitch()
                switchView.isOn = groupDefaults.bool(forKey: ShowScoreKey)
                switchView.onTintColor = QSCColor.theme
                switchView.addTarget(self, action: #selector(showScoreSwitchChanged), for: .valueChanged)
                cell.accessoryView = switchView
                return cell
            case 2:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.textLabel!.attributedText = "\u{f0f6}\t辅助成绩显示".attributedWithFontAwesome
                let segmentedControl = UISegmentedControl(items: ["四／百分制", "主修成绩"])
                segmentedControl.selectedSegmentIndex = groupDefaults.integer(forKey: AuxiliaryScoreKey)
                segmentedControl.tintColor = QSCColor.theme
                segmentedControl.addTarget(self, action: #selector(auxiliaryScoreChanged), for: .valueChanged)
                cell.accessoryView = segmentedControl
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
                cell.textLabel!.text = "给应用评分"
            default:
                return UITableViewCell()
            }
            cell.textLabel!.textColor = ColorCompatibility.label
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
                vc.delegate = self
                present(vc, animated: true)
            }
        case .zjuwlan:
            if indexPath.row == 0{
                let vc = ZjuwlanLoginViewController()
                show(vc, sender: nil)
            } else {
                SVProgressHUD.show(withStatus: "连接中")
                ZjuwlanConnection.link { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: error)
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "连接成功")
                    }
                }
            }
        case .about:
            switch indexPath.row {
            case 0:
                let vc = AboutViewController()
                vc.hidesBottomBarWhenPushed = true
                show(vc, sender: nil)
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
            case 1:
                UIApplication.shared.openURL(URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=515794930")!)
            case 2:
                let vc = SKStoreProductViewController()
                vc.delegate = self
                vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: 583334920])
                present(vc, animated: true)
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
    
    @objc func refreshSwitchChanged(_ sender: UISwitch) {
        groupDefaults.set(sender.isOn, forKey: RefreshOnLaunchKey)
    }
    
    @objc func showScoreSwitchChanged(_ sender: UISwitch) {
        groupDefaults.set(sender.isOn, forKey: ShowScoreKey)
        let auxRow = IndexPath(row: 2, section: Preference.setting.rawValue)
        if sender.isOn {
            tableView.insertRows(at: [auxRow], with: .automatic)
        } else {
            tableView.deleteRows(at: [auxRow], with: .automatic)
        }
    }
    
    @objc func auxiliaryScoreChanged(_ sender: UISegmentedControl) {
        groupDefaults.set(sender.selectedSegmentIndex, forKey: AuxiliaryScoreKey)
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
            let action = UIAlertAction(title: "好", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
}

extension PreferenceViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss(animated: true)
    }
    
}
