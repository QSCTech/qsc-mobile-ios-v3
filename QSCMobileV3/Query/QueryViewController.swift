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
    
    private let accountManager = AccountManager.sharedInstance
    private let collectionViewDelegate = QueryCollectionViewDelegate()
    
    enum Tools: Int {
        case Score = 0, Query, Login, Website, Webpage
        static let count = 5
    }
    
    private let login: [[String: String]] = [
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
    
    private let websites: [[String: String]] = [
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
            "url": "http://www.tyys.zju.edu.cn:8080/tzjk/",
            "campus": "on",
        ],
        [
            "name": "健康之友",
            "url": "http://www.tyys.zju.edu.cn:8080/hyz/",
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
    
    private let webpages: [[String: String]] = [
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
            "name": "校园地图",
            "url": "http://m.zju.edu.cn:8080/m/maps/zjg.html",
            "campus": "on",
        ],
        [
            "name": "教室占用查询",
            "url": "http://jxzygl.zju.edu.cn/jxzwsyqk/jszycx.aspx",
            "campus": "on",
        ],
    ]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Tools.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Tools.Score.rawValue:
            return 1
        case Tools.Query.rawValue:
            return 1
        case Tools.Login.rawValue:
            return login.count
        case Tools.Website.rawValue:
            return websites.count
        case Tools.Webpage.rawValue:
            return webpages.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Tools.Login.rawValue:
            return "一键登录"
        case Tools.Website.rawValue:
            return "校网链接"
        case Tools.Webpage.rawValue:
            return "实用查询"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Basic")!
        switch indexPath.section {
        case Tools.Score.rawValue:
            if accountManager.currentAccountForJwbinfosys == nil {
                cell.textLabel!.attributedText = "\u{f0f6}\t查询成绩请先登录".attributedWithFontAwesome
            } else if MobileManager.sharedInstance.statistics == nil {
                cell.textLabel!.attributedText = "\u{f0f6}\t暂无成绩数据，请下拉刷新".attributedWithFontAwesome
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("Score") as! OverallScoreCell
                if groupDefaults.boolForKey(ShowScoreKey) {
                    let statistics = MobileManager.sharedInstance.statistics
                    cell.averageGradeLabel.text = String(format: "%.2f", statistics!.averageGrade!.floatValue)
                    cell.totalCreditLabel.text = statistics!.totalCredit!.stringValue
                    cell.majorGradeLabel.text = String(format: "%.2f", statistics!.majorGrade!.floatValue)
                    cell.majorCreditLabel.text = statistics!.majorCredit!.stringValue
                } else {
                    cell.hideAll()
                }
                return cell
            }
        case Tools.Query.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("Collection") as! QueryTableViewCell
            cell.collectionView.registerNib(UINib(nibName: "QueryCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
            cell.collectionView.delegate = collectionViewDelegate
            cell.collectionView.dataSource = collectionViewDelegate
            cell.selectionStyle = .None
            return cell
        case Tools.Login.rawValue:
            cell.textLabel!.text = login[indexPath.row]["name"]
        case Tools.Website.rawValue:
            cell.textLabel!.text = websites[indexPath.row]["name"]
        case Tools.Webpage.rawValue:
            cell.textLabel!.text = webpages[indexPath.row]["name"]
        default:
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case Tools.Score.rawValue:
            if accountManager.currentAccountForJwbinfosys == nil {
                let vc = JwbinfosysLoginViewController()
                presentViewController(vc, animated: true, completion: nil)
            } else if MobileManager.sharedInstance.statistics != nil {
                let vc = ScoreViewController()
                presentViewController(vc, animated: true, completion: nil)
            }
        case Tools.Login.rawValue:
            if indexPath.row == 0 && accountManager.currentAccountForJwbinfosys == nil {
                let vc = JwbinfosysLoginViewController()
                presentViewController(vc, animated: true, completion: nil)
                break
            }
            if 1 <= indexPath.row && indexPath.row <= 2 && accountManager.accountForZjuwlan == nil {
                SVProgressHUD.showErrorWithStatus("您未设置 ZJUWLAN 账号")
                break
            }
            // TODO: Handle login errors
            let url = NSURL(string: login[indexPath.row]["url"]!)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            switch indexPath.row {
            case 0:
                let username = accountManager.currentAccountForJwbinfosys!.percentEncoded
                let password = accountManager.passwordForJwbinfosys(username)!.percentEncoded
                request.HTTPBody = "__EVENTTARGET=Button1&__EVENTARGUMENT=&__VIEWSTATE=dDwxNTc0MzA5MTU4Ozs%2BRGE82%2BDpWCQpVjFtEpHZ1UJYg8w%3D&TextBox1=\(username)&TextBox2=\(password)&RadioButtonList1=%D1%A7%C9%FA&Text1=".dataUsingEncoding(NSASCIIStringEncoding)
            case 1:
                let username = accountManager.accountForZjuwlan!.percentEncoded
                let password = accountManager.passwordForZjuwlan!.percentEncoded
                request.HTTPBody = "service=PHONE&face=XJS&locale=zh_CN&destURL=%2Fcoremail%2Fxphone%2Fmain.jsp&uid=\(username)&password=\(password)&action%3Alogin=".dataUsingEncoding(NSASCIIStringEncoding)
            case 2:
                let username = accountManager.accountForZjuwlan!.percentEncoded
                let password = accountManager.passwordForZjuwlan!.percentEncoded
                request.HTTPBody = "j_username=\(username)&j_password=\(password)".dataUsingEncoding(NSASCIIStringEncoding)
            default:
                break
            }
            let bvc = BrowserViewController(request: request)
            presentViewController(bvc, animated: true, completion: nil)
        case Tools.Website.rawValue:
            let url = NSURL(string: websites[indexPath.row]["url"]!)!
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(URL: url)
                presentViewController(svc, animated: true, completion: nil)
            } else {
                let request = NSURLRequest(URL: url)
                let bvc = BrowserViewController(request: request)
                presentViewController(bvc, animated: true, completion: nil)
            }
        case Tools.Webpage.rawValue:
            let url = webpages[indexPath.row]["url"]!
            let title = webpages[indexPath.row]["name"]!
            let wvc = WebViewController(url: url, title: title)
            showViewController(wvc, sender: nil)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == Tools.Score.rawValue {
            return 77
        } else if indexPath.section == Tools.Query.rawValue {
            return 81
        } else {
            return 44
        }
    }
    
    let refreshCtl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewDelegate.viewController = self
        tableView.registerNib(UINib(nibName: "OverallScoreCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Score")
        tableView.registerClass(QueryTableViewCell.self, forCellReuseIdentifier: "Collection")
        refreshCtl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        // Placeholder to prevent activity indicator from changing its position
        refreshCtl.attributedTitle = NSAttributedString(string: " ")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadSections(NSIndexSet(index: Tools.Score.rawValue), withRowAnimation: .Automatic)
        if accountManager.currentAccountForJwbinfosys == nil {
            refreshControl = nil
        } else {
            refreshControl = refreshCtl
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        MobileManager.sharedInstance.refreshAll({ notification in
            sender.attributedTitle = NSAttributedString(string: notification.userInfo!["error"] as! String)
        }, callback: {
            if sender.attributedTitle?.string == " " {
                sender.attributedTitle = NSAttributedString(string: "刷新成功")
            }
            delay(1) {
                sender.endRefreshing()
                sender.attributedTitle = NSAttributedString(string: " ")
            }
            self.tableView.reloadSections(NSIndexSet(index: Tools.Score.rawValue), withRowAnimation: .Automatic)
        })
    }
    
}
