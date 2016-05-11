//
//  ToolsViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class ToolsViewController: UITableViewController {
    
    private let accountManager = AccountManager.sharedInstance
    
    enum Tools: Int {
        case Query = 0, Website, Webpage
        static let count = 3
    }
    
    private let queries: [[String: String]] = [
        [
            "name": "课程",
            "segue": "showCourse",
        ],
        [
            "name": "考试",
            "segue": "showExam",
        ],
        [
            "name": "成绩",
            "segue": "showScore",
        ],
        [
            "name": "校车",
            "segue": "showBus",
        ],
    ]
    
    private let websites: [[String: String]] = [
        [
            "name": "教务网",
            "url": "http://jwbinfosys.zju.edu.cn/default2.aspx",
        ],
        [
            "name": "浙大邮箱",
            "url": "https://mail.zju.edu.cn/coremail/login.jsp",
        ],
        [
            "name": "网络中心",
            "url": "http://myvpn.zju.edu.cn/j_security_check",
        ],
    ]
    
    private let webpages: [[String: String]] = [
        [
            "name": "学年校历",
            "url": "https://info.zjuqsc.com/academic-calendar/",
        ],
        [
            "name": "校园地图",
            "url": "http://m.zju.edu.cn:8080/m/maps/zjg.html",
        ],
        [
            "name": "浙大图书馆",
            "url": "http://m.5read.com/zju",
        ],
        [
            "name": "信息共享空间",
            "url": "http://ic.zju.edu.cn/ClientWeb/xcus/zd/index.aspx",
        ],
        [
            "name": "教室占用查询",
            "url": "http://jxzygl.zju.edu.cn/jxzwsyqk/jszycx.aspx",
        ],
    ]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Tools.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Tools.Query.rawValue:
            return queries.count
        case Tools.Website.rawValue:
            return websites.count
        case Tools.Webpage.rawValue:
            return webpages.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        switch indexPath.section {
        case Tools.Query.rawValue:
            cell.textLabel!.text = queries[indexPath.row]["name"]
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
        case Tools.Query.rawValue:
            performSegueWithIdentifier(queries[indexPath.row]["segue"]!, sender: nil)
        case Tools.Website.rawValue:
            // TODO: Check whether logged in
            // TODO: Handle login errors
            let url = NSURL(string: websites[indexPath.row]["url"]!)!
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
                request.HTTPBody = "service=PHONE&face=XJS&locale=zh_CN&destURL=%2Fcoremail%2Fxphone%2Fmain.jsp&uid=\(username)&password=\(password)&action:login=".dataUsingEncoding(NSASCIIStringEncoding)
            case 2:
                let username = accountManager.accountForZjuwlan!.percentEncoded
                let password = accountManager.passwordForZjuwlan!.percentEncoded
                request.HTTPBody = "j_username=\(username)&j_password=\(password)".dataUsingEncoding(NSASCIIStringEncoding)
            default:
                break
            }
            let bvc = BrowserViewController(request: request)
            presentViewControllerWithAnimation(bvc)
        case Tools.Webpage.rawValue:
            let url = webpages[indexPath.row]["url"]!
            let title = webpages[indexPath.row]["name"]!
            let wvc = WebViewController(url: url, title: title)
            showViewController(wvc, sender: nil)
        default:
            break
        }
    }

}
