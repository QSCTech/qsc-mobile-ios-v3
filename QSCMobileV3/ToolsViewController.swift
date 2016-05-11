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

    private let tools: [[String: String]] = [
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
    ]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tools.count
        } else {
            return websites.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        if indexPath.section == 0 {
            cell.textLabel!.text = tools[indexPath.row]["name"]
        } else {
            cell.textLabel!.text = websites[indexPath.row]["name"]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            performSegueWithIdentifier(tools[indexPath.row]["segue"]!, sender: nil)
        } else {
            let url = NSURL(string: websites[indexPath.row]["url"]!)!
            if indexPath.row == 0 {
                let username = accountManager.currentAccountForJwbinfosys!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                let password = accountManager.passwordForJwbinfosys(username)!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = "__EVENTTARGET=Button1&__EVENTARGUMENT=&__VIEWSTATE=dDwxNTc0MzA5MTU4Ozs%2BRGE82%2BDpWCQpVjFtEpHZ1UJYg8w%3D&TextBox1=\(username)&TextBox2=\(password)&RadioButtonList1=%D1%A7%C9%FA&Text1=".dataUsingEncoding(NSASCIIStringEncoding)
                let bvc = BrowserViewController(request: request)
                presentViewControllerWithAnimation(bvc)
            }
        }
    }

}
