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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // To avoid dark shadow during transition
        navigationController?.view.backgroundColor = UIColor.white
        navigationController?.setToolbarHidden(false, animated: animated)
        
        let category = Event.Category(rawValue: customEvent.category!.intValue)!
        navigationItem.title = category.name
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorCompatibility.label]
        dotView.backgroundColor = QSCColor.category(category)
        nameLabel.text = customEvent.name
        placeLabel.text = customEvent.place
        if customEvent.duration!.intValue == Event.Duration.allDay.rawValue {
            startLabel.text = customEvent.start!.stringOfDate
            endLabel.text = customEvent.end!.stringOfDate
        } else {
            startLabel.text = customEvent.start!.stringOfDatetime
            if Calendar.current.isDate(customEvent.start!, inSameDayAs: customEvent.end!) {
                endLabel.text = customEvent.end!.stringOfTime
            } else {
                endLabel.text = customEvent.end!.stringOfDatetime
            }
        }
        repeatTypeLabel.text = customEvent.repeatType
        repeatEndLabel.text = customEvent.repeatEnd!.stringOfDate
        notificationLabel.text = customEvent.notification!.stringFromNotificationType
        notesTextView.text = customEvent.notes
        
        view.backgroundColor = UIColor.groupTableViewBackground
        nameLabel.textColor = ColorCompatibility.label
        placeLabel.textColor = ColorCompatibility.label
        notesTextView.backgroundColor = UIColor(white: 0, alpha: 0)
        
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = segue.destination as! UINavigationController
        let vc = nc.topViewController as! EventEditViewController
        vc.customEvent = customEvent
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 3 {
            return repeatTypeLabel.text == "永不" ? 0 : 44
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func edit(_ sender: AnyObject) {
        performSegue(withIdentifier: "Edit", sender: nil)
    }
    
    @IBAction func remove(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let remove = UIAlertAction(title: "确认删除", style: .destructive) { _ in
            for notif in UIApplication.shared.scheduledLocalNotifications!.filter({ $0.userInfo!["objectID"] as! String == self.customEvent.objectID.uriRepresentation().absoluteString }) {
                UIApplication.shared.cancelLocalNotification(notif)
            }
            if self.customEvent.repeatType != "永不" {
                NotificationCenter.default.post(name: .eventsModified, object: nil)
            } else {
                NotificationCenter.default.post(name: .eventsModified, object: nil, userInfo: ["start": self.customEvent.start!, "end": self.customEvent.end!])
            }
            EventManager.sharedInstance.removeCustomEvent(self.customEvent)
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(remove)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = toolbarItems![1]
        present(alert, animated: true)
    }
    
}
