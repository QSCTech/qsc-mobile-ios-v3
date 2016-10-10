//
//  QueryViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import SafariServices
import SVProgressHUD
import QSCMobileKit

class QueryViewController: UITableViewController {
    
    let accountManager = AccountManager.sharedInstance
    let collectionViewDelegate = QueryCollectionViewDelegate()
    
    enum Tools: Int {
        case score = 0, query, login, website, webpage
        static let count = 5
    }
    
    let login: [[String: String]] = [
        [
            "name": "教务网",
            "url": "http://jwbinfosys.zju.edu.cn/default2.aspx",
            "campus": "off",
        ],
        [
            "name": "浙大邮箱",
            "url": "http://mail.zju.edu.cn/coremail/login.jsp",
            "campus": "off",
        ],
        [
            "name": "网络中心",
            "url": "http://myvpn.zju.edu.cn/j_security_check",
            "campus": "on",
        ],
    ]
    
    let websites: [[String: String]] = [
        [
            "name": "院系网站",
            "url": "https://info.zjuqsc.com/zju-websites/",
            "campus": "off",
        ],
        [
            "name": "图书馆",
            "url": "http://webpac.zju.edu.cn",
            "campus": "off",
        ],
        [
            "name": "体质健康测试",
            "url": "http://www.tyys.zju.edu.cn/tzjk/indexphone.jsp",
            "campus": "on",
        ],
        [
            "name": "健康之友",
            "url": "http://www.tyys.zju.edu.cn/hyz/indexphone.jsp",
            "campus": "on",
        ],
        [
            "name": "第二课堂",
            "url": "http://www.qzlake.zju.edu.cn",
            "campus": "on",
        ],
        [
            "name": "综合数据服务平台",
            "url": "http://zuds.zju.edu.cn/zfsjzx/jspdspp/zjuindex/index.jsp",
            "campus": "on",
        ],
    ]
    
    let webpages: [[String: String]] = [
        [
            "name": "学年校历",
            "url": "https://info.zjuqsc.com/academic-calendar/",
            "campus": "off",
        ],
        [
            "name": "体育锻炼制度",
            "url": "https://info.zjuqsc.com/exercise-regulations/",
            "campus": "off",
        ],
        [
            "name": "教室占用查询",
            "url": "http://jxzygl.zju.edu.cn/jxzwsyqk/jszycx.aspx",
            "campus": "on",
        ],
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Tools.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Tools.score.rawValue:
            return 1
        case Tools.query.rawValue:
            return 1
        case Tools.login.rawValue:
            return login.count
        case Tools.website.rawValue:
            return websites.count
        case Tools.webpage.rawValue:
            return webpages.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Tools.login.rawValue:
            return "一键登录"
        case Tools.website.rawValue:
            return "校网链接"
        case Tools.webpage.rawValue:
            return "实用查询"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
        switch indexPath.section {
        case Tools.score.rawValue:
            if accountManager.currentAccountForJwbinfosys == nil {
                cell.textLabel!.attributedText = "\u{f0f6}\t查询成绩请先登录".attributedWithFontAwesome
            } else if MobileManager.sharedInstance.statistics == nil {
                cell.textLabel!.attributedText = "\u{f0f6}\t暂无成绩数据，请下拉刷新".attributedWithFontAwesome
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Score") as! OverallScoreCell
                if groupDefaults.bool(forKey: ShowScoreKey) {
                    let statistics = MobileManager.sharedInstance.statistics
                    cell.totalCreditLabel.text = statistics!.totalCredit!.stringValue
                    cell.averageGradeLabel.text = String(format: "%.2f", statistics!.averageGrade!.floatValue)
                    if let overseaScore = MobileManager.sharedInstance.overseaScore {
                        cell.fourPointLabel.text = String(format: "%.2f", overseaScore.fourPoint!.floatValue)
                        cell.hundredPointLabel.text = String(format: "%.1f", overseaScore.hundredPoint!.floatValue)
                    } else {
                        cell.fourPointLabel.text = "-"
                        cell.hundredPointLabel.text = "-"
                    }
                } else {
                    cell.hideAll()
                }
                return cell
            }
        case Tools.query.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection") as! QueryTableViewCell
            cell.collectionView.register(UINib(nibName: "QueryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
            cell.collectionView.delegate = collectionViewDelegate
            cell.collectionView.dataSource = collectionViewDelegate
            cell.selectionStyle = .none
            return cell
        case Tools.login.rawValue:
            cell.textLabel!.text = login[indexPath.row]["name"]
        case Tools.website.rawValue:
            cell.textLabel!.text = websites[indexPath.row]["name"]
        case Tools.webpage.rawValue:
            cell.textLabel!.text = webpages[indexPath.row]["name"]
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case Tools.score.rawValue:
            if accountManager.currentAccountForJwbinfosys == nil {
                let vc = JwbinfosysLoginViewController()
                present(vc, animated: true, completion: nil)
            } else if MobileManager.sharedInstance.statistics != nil {
                let vc = ScoreViewController()
                present(vc, animated: true, completion: nil)
            }
        case Tools.login.rawValue:
            if indexPath.row == 0 && accountManager.currentAccountForJwbinfosys == nil {
                let vc = JwbinfosysLoginViewController()
                present(vc, animated: true, completion: nil)
                break
            }
            if 1 <= indexPath.row && indexPath.row <= 2 && accountManager.accountForZjuwlan == nil {
                SVProgressHUD.showError(withStatus: "您未设置 ZJUWLAN 账号")
                break
            }
            // TODO: Handle login errors
            let url = URL(string: login[indexPath.row]["url"]!)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            switch indexPath.row {
            case 0:
                let username = accountManager.currentAccountForJwbinfosys!.percentEncoded
                let password = accountManager.passwordForJwbinfosys(username)!.percentEncoded
                request.httpBody = "__EVENTTARGET=Button1&__EVENTARGUMENT=&__VIEWSTATE=dDwxNTc0MzA5MTU4Ozs%2BRGE82%2BDpWCQpVjFtEpHZ1UJYg8w%3D&TextBox1=\(username)&TextBox2=\(password)&RadioButtonList1=%D1%A7%C9%FA&Text1=".data(using: String.Encoding.ascii)
            case 1:
                let username = accountManager.accountForZjuwlan!.percentEncoded
                let password = accountManager.passwordForZjuwlan!.percentEncoded
                request.httpBody = "service=PHONE&face=XJS&locale=zh_CN&destURL=%2Fcoremail%2Fxphone%2Fmain.jsp&uid=\(username)&password=\(password)&action%3Alogin=".data(using: String.Encoding.ascii)
            case 2:
                let username = accountManager.accountForZjuwlan!.percentEncoded
                let password = accountManager.passwordForZjuwlan!.percentEncoded
                request.httpBody = "j_username=\(username)&j_password=\(password)".data(using: String.Encoding.ascii)
            default:
                break
            }
            let bvc = BrowserViewController(request: request)
            present(bvc, animated: true, completion: nil)
        case Tools.website.rawValue:
            let url = URL(string: websites[indexPath.row]["url"]!)!
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        case Tools.webpage.rawValue:
            let url = webpages[indexPath.row]["url"]!
            let title = webpages[indexPath.row]["name"]!
            let wvc = WebViewController(url: url, title: title)
            show(wvc, sender: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Tools.score.rawValue {
            return 77
        } else if indexPath.section == Tools.query.rawValue {
            return 81
        } else {
            return 44
        }
    }
    
    let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewDelegate.viewController = self
        tableView.register(UINib(nibName: "OverallScoreCell", bundle: Bundle.main), forCellReuseIdentifier: "Score")
        tableView.register(QueryTableViewCell.self, forCellReuseIdentifier: "Collection")
        refreshCtl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        // Placeholder to prevent activity indicator from changing its position
        refreshCtl.attributedTitle = NSAttributedString(string: " ")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadSections(IndexSet(integer: Tools.score.rawValue), with: .automatic)
        if accountManager.currentAccountForJwbinfosys == nil {
            refreshControl = nil
        } else {
            refreshControl = refreshCtl
        }
    }
    
    func refresh(_ sender: UIRefreshControl) {
        MobileManager.sharedInstance.refreshAll({ notification in
            sender.attributedTitle = NSAttributedString(string: notification.userInfo?["error"] as? String ?? "")
        }, callback: {
            if sender.attributedTitle?.string == " " {
                sender.attributedTitle = NSAttributedString(string: "刷新成功")
            }
            delay(1) {
                sender.endRefreshing()
                sender.attributedTitle = NSAttributedString(string: " ")
            }
            self.tableView.reloadSections(IndexSet(integer: Tools.score.rawValue), with: .automatic)
        })
    }
    
}
