//
//  EventNotificationViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-14.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

let EventNotificationKey = "EventNotification"

private let titlesForEventNotification = [
    "永不",
    "准时",
    "5 分钟前",
    "10 分钟前",
    "15 分钟前",
    "30 分钟前",
    "1 小时前",
]

class EventNotificationViewController: UITableViewController {
        
    static var status: String {
        return titlesForEventNotification[groupDefaults.integerForKey(EventNotificationKey)]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesForEventNotification.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel!.text = titlesForEventNotification[indexPath.row]
        if indexPath.row == groupDefaults.integerForKey(EventNotificationKey) {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        tableView.cellForRowAtIndexPath(indexPath)!.accessoryType = .Checkmark
        tableView.cellForRowAtIndexPath(NSIndexPath(forRow: groupDefaults.integerForKey(EventNotificationKey), inSection: indexPath.section))!.accessoryType = .None
        groupDefaults.setInteger(indexPath.row, forKey: EventNotificationKey)
    }
    
}
