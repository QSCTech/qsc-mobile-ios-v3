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
        case score = 0, query, qsc, login, website, webpage, annotation
        static let count = 7
    }
    
    let qsc = ["Box 云优盘", "水朝夕"]
    
    let login = ["教务网", "浙大邮箱", "网络中心*"]
    
    let websites: [[String: String]] = [
        [
            "name": "院系网站",
            "url": "https://info.zjuqsc.com/zju-websites/",
        ],
        [
            "name": "图书馆",
            "url": "http://webpac.zju.edu.cn",
        ],
        [
            "name": "信息共享空间",
            "url": "http://ic.zju.edu.cn/ClientWeb/m/ic2/Default.aspx",
        ],
        [
            "name": "公共体育信息平台",
            "url": "http://www.tyys.zju.edu.cn/ggtypt/login",
        ],
        [
            "name": "第二课堂",
            "url": "http://www.youth.zju.edu.cn/sztz/",
        ],
    ]
    
    let webpages: [[String: String]] = [
        [
            "name": "教室占用查询",
            "url": "https://app.zjuqsc.com/classroom/",
        ],
        [
            "name": "校园地图",
            "url": "http://map.zju.edu.cn/mobile/index",
        ],
        [
            "name": "学年校历",
            "url": "https://info.zjuqsc.com/academic-calendar/",
        ],
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Tools.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Tools(rawValue: section)! {
        case .score:
            return 1
        case .query:
            return 1
        case .qsc:
            return qsc.count
        case .login:
            return login.count
        case .website:
            return websites.count
        case .webpage:
            return webpages.count
        case .annotation:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Tools(rawValue: section)! {
        case .login:
            return "一键登录"
        case .website:
            return "校网链接"
        case .webpage:
            return "实用查询"
        case .annotation:
            return "* 加星号的网站仅限校内访问"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
        cell.textLabel!.textColor = ColorCompatibility.label
        switch Tools(rawValue: indexPath.section)! {
        case .score:
            if accountManager.currentAccountForJwbinfosys == nil {
                cell.textLabel!.attributedText = "\u{f0f6}\t查询成绩请先登录".attributedWithFontAwesome
            } else if MobileManager.sharedInstance.statistics == nil {
                cell.textLabel!.attributedText = "\u{f0f6}\t暂无成绩数据，请下拉刷新".attributedWithFontAwesome
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Score") as! OverallScoreCell
                if groupDefaults.integer(forKey: AuxiliaryScoreKey) == 0 {
                    cell.auxKeyLabel1.text = "四分制"
                    cell.auxKeyLabel2.text = "百分制"
                } else {
                    cell.auxKeyLabel1.text = "主修学分"
                    cell.auxKeyLabel2.text = "主修绩点"
                }
                if groupDefaults.bool(forKey: ShowScoreKey) {
                    let statistics = MobileManager.sharedInstance.statistics!
                    cell.totalCreditLabel.text = statistics.totalCredit!.stringValue
                    let grade = statistics.averageGrade!.floatValue
                    // GPA is not available from graduate API.
                    cell.averageGradeLabel.text = String(format: "%.2f", grade > 0 ? grade : MobileManager.sharedInstance.calculatedGPA)
                    if groupDefaults.integer(forKey: AuxiliaryScoreKey) == 0 {
                        if let overseaScore = MobileManager.sharedInstance.overseaScore {
                            cell.auxValueLabel1.text = String(format: "%.2f", overseaScore.fourPoint!.floatValue)
                            cell.auxValueLabel2.text = String(format: "%.1f", overseaScore.hundredPoint!.floatValue)
                        } else {
                            cell.auxValueLabel1.text = "-"
                            cell.auxValueLabel2.text = "-"
                        }
                    } else {
                        cell.auxValueLabel1.text = statistics.majorCredit!.stringValue
                        cell.auxValueLabel2.text = String(format: "%.2f", statistics.majorGrade!.floatValue)
                    }
                } else {
                    cell.hideAll()
                }
                cell.auxValueLabel1.textColor = ColorCompatibility.label
                cell.auxValueLabel2.textColor = ColorCompatibility.label
                cell.totalCreditLabel.textColor = ColorCompatibility.label
                cell.averageGradeLabel.textColor = ColorCompatibility.label
                return cell
            }
        case .query:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Collection") as! QueryTableViewCell
            cell.collectionView.register(UINib(nibName: "QueryCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
            cell.collectionView.delegate = collectionViewDelegate
            cell.collectionView.dataSource = collectionViewDelegate
            cell.selectionStyle = .none
            return cell
        case .qsc:
            cell.textLabel!.text = qsc[indexPath.row]
        case .login:
            cell.textLabel!.text = login[indexPath.row]
        case .website:
            cell.textLabel!.text = websites[indexPath.row]["name"]
        case .webpage:
            cell.textLabel!.text = webpages[indexPath.row]["name"]
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Tools(rawValue: indexPath.section)! {
        case .score:
            if accountManager.currentAccountForJwbinfosys == nil {
                let vc = JwbinfosysLoginViewController()
                present(vc, animated: true)
            } else if MobileManager.sharedInstance.statistics != nil {
                let vc = ScoreViewController()
                present(vc, animated: true)
            }
        case .qsc:
            switch indexPath.row {
            case 0:
                let storyboard = UIStoryboard(name: "Box", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()!
                show(vc, sender: nil)
            case 1:
                let svc = SFSafariViewController(url: URL(string: TideURL)!)
                present(svc, animated: true)
            default:
                break
            }
        case .login:
            if indexPath.row == 0 && accountManager.currentAccountForJwbinfosys == nil {
                let vc = JwbinfosysLoginViewController()
                present(vc, animated: true)
                break
            }
            if 1 <= indexPath.row && indexPath.row <= 2 && accountManager.accountForZjuwlan == nil {
                SVProgressHUD.showError(withStatus: "您未设置 ZJUWLAN 账号")
                break
            }
            let website: BrowserViewController.Website
            switch indexPath.row {
            case 0:
                website = .jwbinfosys
            case 1:
                website = .mail
            default:
                website = .myvpn
            }
            let bvc = BrowserViewController.builtin(website: website)
            present(bvc, animated: true)
        case .website:
            let url = URL(string: websites[indexPath.row]["url"]!)!
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true)
        case .webpage:
            let url = webpages[indexPath.row]["url"]!
            let title = webpages[indexPath.row]["name"]!.replacingOccurrences(of: "*", with: "")
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
        
        NotificationCenter.default.addObserver(forName: .refreshCompleted, object: nil, queue: .main) { _ in
            self.tableView.reloadSections(IndexSet(integer: Tools.score.rawValue), with: .automatic)
        }
        
        tableView?.backgroundColor = UIColor.groupTableViewBackground
        navigationController?.navigationBar.barTintColor = ColorCompatibility.systemGray6
        
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
    
    @objc func refresh(_ sender: UIRefreshControl) {
        var errorFlag = false
        let observer = NotificationCenter.default.addObserver(forName: .refreshError, object: nil, queue: .main) { _ in errorFlag = true }
        MobileManager.sharedInstance.refreshAll {
            if !errorFlag {
                sender.attributedTitle = NSAttributedString(string: "刷新成功")
            }
            NotificationCenter.default.removeObserver(observer)
            groupDefaults.set(Date(), forKey: LastRefreshDateKey)
            delay(1) {
                sender.endRefreshing()
                sender.attributedTitle = NSAttributedString(string: " ")
            }
        }
    }
    
}
