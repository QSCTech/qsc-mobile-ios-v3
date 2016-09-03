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
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    // MARK: - View controller override
    
    var customEvent: CustomEvent!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // To avoid dark shadow during transition
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        navigationController?.setToolbarHidden(false, animated: animated)
        
        let category = Event.Category(rawValue: customEvent.category!.integerValue)!
        navigationItem.title = category.name
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        dotView.backgroundColor = QSCColor.category(category)
        nameLabel.text = customEvent.name
        placeLabel.text = customEvent.place
        if customEvent.duration == Event.Duration.AllDay.rawValue {
            startLabel.text = EventDetailViewController.stringFromDate(customEvent.start!)
            endLabel.text = EventDetailViewController.stringFromDate(customEvent.end!)
        } else {
            startLabel.text = EventDetailViewController.stringFromDatetime(customEvent.start!)
            if NSCalendar.currentCalendar().isDate(customEvent.start!, inSameDayAsDate: customEvent.end!) {
                endLabel.text = EventDetailViewController.stringFromTime(customEvent.end!)
            } else {
                endLabel.text = EventDetailViewController.stringFromDatetime(customEvent.end!)
            }
        }
        repeatTypeLabel.text = customEvent.repeatType
        repeatEndLabel.text = EventDetailViewController.stringFromDate(customEvent.repeatEnd!)
        notificationLabel.text = customEvent.notification!.stringFromNotificationType
        notesTextView.text = customEvent.notes
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nc = segue.destinationViewController as! UINavigationController
        let vc = nc.topViewController as! EventEditViewController
        vc.customEvent = customEvent
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 3 {
            return repeatTypeLabel.text == "永不" ? 0 : 44
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func edit(sender: AnyObject) {
        performSegueWithIdentifier("Edit", sender: nil)
    }
    
    @IBAction func remove(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let remove = UIAlertAction(title: "确认删除", style: .Destructive) { _ in
            for notif in UIApplication.sharedApplication().scheduledLocalNotifications!.filter({ $0.userInfo!["objectID"] as! String == self.customEvent.objectID.URIRepresentation().URLString }) {
                UIApplication.sharedApplication().cancelLocalNotification(notif)
            }
            EventManager.sharedInstance.removeCustomEvent(self.customEvent)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(remove)
        let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = toolbarItems![1]
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Date formatters
    
    private static let datetimeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy年M月d日    HH:mm"
        return formatter
    }()
    
    static func stringFromDatetime(datetime: NSDate) -> String {
        return datetimeFormatter.stringFromDate(datetime)
    }
    
    static func stringFromDate(date: NSDate) -> String {
        return stringFromDatetime(date).componentsSeparatedByString("    ").first!
    }
    
    static func stringFromTime(time: NSDate) -> String {
        return stringFromDatetime(time).componentsSeparatedByString("    ").last!
    }
    
}
