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
        case score = 0, query, qsc, login, website, webpage
        static let count = 6
    }
    
    let qsc = ["Box 云优盘", "水朝夕"]
    
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
            "name": "信息共享空间",
            "url": "http://ic.zju.edu.cn/ClientWeb/xcus/zd/index.aspx",
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
            "url": "http://www.youth.zju.edu.cn/sztz/",
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
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic")!
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
                    cell.averageGradeLabel.text = String(format: "%.2f", statistics.averageGrade!.floatValue)
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
            cell.textLabel!.text = login[indexPath.row]["name"]
        case .website:
            cell.textLabel!.text = websites[indexPath.row]["name"]
        case .webpage:
            cell.textLabel!.text = webpages[indexPath.row]["name"]
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
            // TODO: Handle login errors
            let url = URL(string: login[indexPath.row]["url"]!)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            switch indexPath.row {
            case 0:
                let username = accountManager.currentAccountForJwbinfosys!.percentEncoded
                let password = accountManager.passwordForJwbinfosys(username)!.percentEncoded
                request.httpBody = "__EVENTTARGET=Button1&__EVENTARGUMENT=&__VIEWSTATE=dDwxNTc0MzA5MTU4Ozs%2Bb5wKASjiu%2BfSjITNzcKuKXEUyXg%3D&TextBox1=\(username)&TextBox2=\(password)&RadioButtonList1=%D1%A7%C9%FA&Text1=".data(using: String.Encoding.ascii)
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
            present(bvc, animated: true)
        case .website:
            let url = URL(string: websites[indexPath.row]["url"]!)!
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true)
        case .webpage:
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
        
        NotificationCenter.default.addObserver(forName: .refreshCompleted, object: nil, queue: .main) { _ in
            self.tableView.reloadSections(IndexSet(integer: Tools.score.rawValue), with: .automatic)
        }
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
        MobileManager.sharedInstance.refreshAll(errorBlock: { notification in
            if let error = notification.userInfo?["error"] as? String {
                sender.attributedTitle = NSAttributedString(string: error)
                if error == "教务网通知，请登录网站查收" {
                    let alertController = UIAlertController(title: "刷新失败", message: "教务网有新通知，需查收后才能刷新", preferredStyle: .alert)
                    let goAction = UIAlertAction(title: "立即前往", style: .default) { action in
                        let url = URL(string: "http://jwbinfosys.zju.edu.cn/default2.aspx")!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        let username = self.accountManager.currentAccountForJwbinfosys!.percentEncoded
                        let password = self.accountManager.passwordForJwbinfosys(username)!.percentEncoded
                        request.httpBody = "__EVENTTARGET=Button1&__EVENTARGUMENT=&__VIEWSTATE=dDwxNTc0MzA5MTU4Ozs%2Bb5wKASjiu%2BfSjITNzcKuKXEUyXg%3D&TextBox1=\(username)&TextBox2=\(password)&RadioButtonList1=%D1%A7%C9%FA&Text1=".data(using: String.Encoding.ascii)
                        let bvc = BrowserViewController(request: request)
                        bvc.webViewDidFinishLoadCallBack = { webView in
                            bvc.webViewDidFinishLoadCallBack = nil
                            webView.loadRequest(URLRequest(url: URL(string:"http://jwbinfosys.zju.edu.cn/xskbcx.aspx?xh=\(username)")!))
                        }
                        self.present(bvc, animated: true)
                    }
                    let cancelAction = UIAlertAction(title: "下次再说", style: .cancel)
                    alertController.addAction(goAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true)
                }
            } else {
                sender.attributedTitle = NSAttributedString(string: "")
            }
            
        }, callback: {
            if sender.attributedTitle?.string == " " {
                sender.attributedTitle = NSAttributedString(string: "刷新成功")
            }
            delay(1) {
                sender.endRefreshing()
                sender.attributedTitle = NSAttributedString(string: " ")
            }
        })
    }
    
}
