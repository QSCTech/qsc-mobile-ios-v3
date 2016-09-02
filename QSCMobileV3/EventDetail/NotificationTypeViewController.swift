//
//  NotificationTypeViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-09-02.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class NotificationTypeViewController: UITableViewController {
    
    var eventEditViewController: EventEditViewController!
    var selectedCell: UITableViewCell!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for cell in tableView.visibleCells {
            if cell.textLabel!.text == eventEditViewController.notificationTypeLabel.text {
                selectedCell = cell
                cell.accessoryType = .Checkmark
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedCell.accessoryType = .None
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        eventEditViewController.notificationTypeLabel.text = cell.textLabel!.text
        navigationController?.popViewControllerAnimated(true)
    }
    
}


private let notificationTypes = [
    (-1,    "永不"),
    (0,     "实时"),
    (300,   "5 分钟前"),
    (600,   "10 分钟前"),
    (900,   "15 分钟前"),
    (1800,  "30 分钟前"),
    (3600,  "1 小时前"),
    (86400, "1 天前"),
]

extension NSNumber {
    
    var stringFromNotificationType: String {
        for (number, string) in notificationTypes {
            if self == number {
                return string
            }
        }
        return ""
    }
    
}

extension String {
    
    var numberFromNotificationType: Int {
        for (number, string) in notificationTypes {
            if self == string {
                return number
            }
        }
        return -1
    }
    
}
