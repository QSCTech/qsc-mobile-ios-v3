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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for cell in tableView.visibleCells {
            if cell.textLabel!.text == eventEditViewController.notificationTypeLabel.text {
                selectedCell = cell
                cell.accessoryType = .checkmark
            }
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCell.accessoryType = .none
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        eventEditViewController.notificationTypeLabel.text = cell.textLabel!.text
        _ = navigationController?.popViewController(animated: true)
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
            if intValue == number {
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
