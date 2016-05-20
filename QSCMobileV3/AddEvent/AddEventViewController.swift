//
//  AddEventViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-19.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class AddEventViewController: UITableViewController {
    
    private let timeSection = 1
    private let notesSection = 3
    
    private enum Time: Int {
        case AllDay = 0
        case StartTime
        case StartPicker
        case EndTime
        case EndPicker
        case RepeatType
        case RepeatEnd
        case RepeatPicker
    }
    
    private let basicHeight: CGFloat = 44
    private let pickerHeight: CGFloat = 200
    private let notesHeight: CGFloat = 150
    
    private var startPickerHeight: CGFloat = 0
    private var endPickerHeight: CGFloat = 0
    private var repeatEndHeight: CGFloat = 0
    private var repeatPickerHeight: CGFloat = 0
    
    @IBOutlet weak var repeatTypeLabel: UILabel!
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case timeSection:
            switch indexPath.row {
            case Time.StartPicker.rawValue:
                return startPickerHeight
            case Time.EndPicker.rawValue:
                return endPickerHeight
            case Time.RepeatEnd.rawValue:
                return repeatEndHeight
            case Time.RepeatPicker.rawValue:
                return repeatPickerHeight
            default:
                return basicHeight
            }
        case notesSection:
            return notesHeight
        default:
            return basicHeight
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != timeSection {
            return
        }
        switch indexPath.row {
        case Time.StartTime.rawValue:
            startPickerHeight = pickerHeight - startPickerHeight
            reloadRowFor(Time.StartPicker, inTableView: tableView)
        case Time.EndTime.rawValue:
            endPickerHeight = pickerHeight - endPickerHeight
            reloadRowFor(Time.EndPicker, inTableView: tableView)
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! RepeatTypeViewController
        vc.repeatTypeLabel = repeatTypeLabel
    }
    
    private func reloadRowFor(row: Time, inTableView tableView: UITableView) {
        let indexPath = NSIndexPath(forRow: row.rawValue, inSection: timeSection)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.reloadData()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
    }
    
}
