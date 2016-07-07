//
//  CourseDetailViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-06.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class CourseDetailViewController: UITableViewController {
    
    var courseObject: Course!
    var courseEvent: CourseEvent!
    
    private enum Detail: Int {
        case Basic = 0, Exam, Info, Homework
        static let count = 4
    }
    
    private enum Info: Int {
        case Teacher = 0, Email, Phone, Website, QQGroup, PublicEmail, PublicPassword
        static let count = 7
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Detail.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Detail.Basic.rawValue:
            return courseObject.timePlaces!.count + 1
        case Detail.Exam.rawValue:
            return 0
        case Detail.Info.rawValue:
            return Info.count
        case Detail.Homework.rawValue:
            return courseEvent.homeworks!.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case Detail.Basic.rawValue:
            switch indexPath.row {
            case 0:
                return 66
            default:
                return 60
            }
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Detail.Basic.rawValue:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("Name") as! CourseNameCell
                cell.nameLabel.text = courseObject.name
                cell.identifierLabel!.text = courseObject.identifier
                cell.categoryLabel!.text = courseObject.category
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("TimePlace") as! CourseTimePlaceCell
                let sortDescriptors = [NSSortDescriptor(key: "weekday", ascending: true), NSSortDescriptor(key: "periods", ascending: true)]
                let timePlace = courseObject.timePlaces!.sortedArrayUsingDescriptors(sortDescriptors)[indexPath.row - 1] as! TimePlace
                cell.placeLabel!.text = timePlace.place!
                cell.timeLabel!.text = timePlace.time!
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
}
