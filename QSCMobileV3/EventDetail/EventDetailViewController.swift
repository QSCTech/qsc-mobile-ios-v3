//
//  EventDetailViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-08-11.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class EventDetailViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var repeatTypeLabel: UILabel!
    @IBOutlet weak var repeatEndLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    // MARK: - View controller override
    
    var customEvent: CustomEvent!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = Event.Category(rawValue: customEvent.category!.integerValue)!.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(edit))
        
        switch customEvent.category! {
        case Event.Category.Lesson.rawValue:
            dotView.backgroundColor = QSCColor.course
        case Event.Category.Quiz.rawValue:
            dotView.backgroundColor = QSCColor.exam
        case Event.Category.Activity.rawValue:
            dotView.backgroundColor = QSCColor.activity
        default:
            dotView.backgroundColor = QSCColor.todo
        }
        nameLabel.text = customEvent.name
        placeLabel.text = customEvent.place
        if customEvent.duration == Event.Duration.AllDay.rawValue {
            startLabel.text = EventDetailViewController.stringFromDate(customEvent.start!)
            endLabel.text = EventDetailViewController.stringFromDate(customEvent.end!)
        } else {
            startLabel.text = EventDetailViewController.stringFromDatetime(customEvent.start!)
            endLabel.text = EventDetailViewController.stringFromDatetime(customEvent.end!)
        }
        repeatTypeLabel.text = customEvent.repeatType
        repeatEndLabel.text = EventDetailViewController.stringFromDate(customEvent.repeatEnd!)
        if customEvent.hasReminder!.boolValue {
            reminderLabel.text = "已开启：" + EventNotificationViewController.status
        } else {
            reminderLabel.text = "未开启"
        }
        notesTextView.text = customEvent.notes
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nc = segue.destinationViewController as! UINavigationController
        let vc = nc.topViewController as! EventEditViewController
        vc.customEvent = customEvent
    }
    
    func edit(sender: AnyObject) {
        performSegueWithIdentifier("Edit", sender: nil)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 3 {
            return repeatTypeLabel.text == "永不" ? 0 : 44
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    // MARK: - Date formatters
    
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
    
    static func stringFromDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    private static let datetimeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy年M月d日    HH:mm"
        return formatter
    }()
    
    static func stringFromDatetime(datetime: NSDate) -> String {
        return datetimeFormatter.stringFromDate(datetime)
    }
    
}
