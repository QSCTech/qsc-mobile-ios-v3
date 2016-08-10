//
//  EventEditViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-19.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class EventEditViewController: UITableViewController {
    
    private let timeSection = 1
    private let notesSection = 2
    
    private enum Time: Int {
        case AllDay = 0
        case StartTime
        case StartPicker
        case EndTime
        case EndPicker
        case RepeatType
        case RepeatEnd
        case RepeatPicker
        case Reminder
    }
    
    // MARK: - Cell heights
    
    private let basicHeight: CGFloat = 44
    private let pickerHeight: CGFloat = 200
    private let notesHeight: CGFloat = 150
    
    private var startPickerHeight: CGFloat = 0
    private var endPickerHeight: CGFloat = 0
    private var repeatEndHeight: CGFloat = 0
    private var repeatPickerHeight: CGFloat = 0
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var placeField: UITextField!
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var repeatTypeLabel: UILabel!
    @IBOutlet weak var repeatEndLabel: UILabel!
    @IBOutlet weak var repeatEndPicker: UIDatePicker!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var notesTextView: UITextView!
    
    // MARK: - View controller override
    
    var customEvent: CustomEvent?
    var selectedDate: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let event = customEvent {
            // TODO: Category / Tags not set
            titleField.text = event.name
            titleDidChange(titleField)
            placeField.text = event.place
            allDaySwitch.on = (event.duration == Event.Duration.AllDay.rawValue)
            allDaySwitchDidChange(allDaySwitch)
            startTimePicker.date = event.start!
            endTimePicker.date = event.end!
            repeatTypeLabel.text = event.repeatType
            changeRepeatType(event.repeatType!)
            repeatEndPicker.date = event.repeatEnd!
            reminderSwitch.on = event.hasReminder!.boolValue
            notesTextView.text = event.notes
        } else {
            startTimePicker.date = selectedDate!
            endTimePicker.date = selectedDate!
            repeatEndPicker.date = selectedDate!
        }
        startTimeDidChange(startTimePicker)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! RepeatTypeViewController
        vc.eventEditViewController = self
    }
    
    // MARK: - Table view delegate
    
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section != timeSection {
            return
        }
        switch indexPath.row {
        case Time.StartTime.rawValue:
            startPickerHeight = pickerHeight - startPickerHeight
            if startPickerHeight > 0 {
                startTimeLabel.textColor = QSCColor.theme
            } else {
                startTimeLabel.textColor = QSCColor.detailText
            }
            reloadRowFor(Time.StartPicker)
        case Time.EndTime.rawValue:
            endPickerHeight = pickerHeight - endPickerHeight
            if endPickerHeight > 0 {
                endTimeLabel.textColor = QSCColor.theme
            } else {
                endTimeLabel.textColor = QSCColor.detailText
            }
            reloadRowFor(Time.EndPicker)
        case Time.RepeatEnd.rawValue:
            repeatPickerHeight = pickerHeight - repeatPickerHeight
            if repeatPickerHeight > 0 {
                repeatEndLabel.textColor = QSCColor.theme
            } else {
                repeatEndLabel.textColor = QSCColor.detailText
            }
            reloadRowFor(Time.RepeatPicker)
        default:
            break
        }
    }
    
    // MARK: - Reload row
    
    private func reloadRowFor(row: Time) {
        let indexPath = NSIndexPath(forRow: row.rawValue, inSection: timeSection)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.reloadData()
    }
    
    func changeRepeatType(type: String) {
        if type == "永不" {
            repeatEndHeight = 0
            reloadRowFor(Time.RepeatEnd)
        } else {
            repeatEndHeight = basicHeight
            reloadRowFor(Time.RepeatEnd)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func titleDidChange(sender: UITextField) {
        if sender.text!.isEmpty {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
    
    @IBAction func allDaySwitchDidChange(sender: UISwitch) {
        if sender.on {
            startTimePicker.datePickerMode = .Date
            endTimePicker.datePickerMode = .Date
            startTimeLabel.text = EventDetailViewController.stringFromDate(startTimePicker.date)
            endTimeLabel.text = EventDetailViewController.stringFromDate(endTimePicker.date)
        } else {
            startTimePicker.datePickerMode = .DateAndTime
            endTimePicker.datePickerMode = .DateAndTime
            startTimeLabel.text = EventDetailViewController.stringFromDatetime(startTimePicker.date)
            endTimeLabel.text = EventDetailViewController.stringFromDatetime(endTimePicker.date)
        }
    }
    
    @IBAction func startTimeDidChange(sender: UIDatePicker) {
        if allDaySwitch.on {
            startTimeLabel.text = EventDetailViewController.stringFromDate(sender.date)
        } else {
            startTimeLabel.text = EventDetailViewController.stringFromDatetime(sender.date)
        }
        endTimePicker.minimumDate = sender.date
        endTimeDidChange(endTimePicker)
    }
    
    @IBAction func endTimeDidChange(sender: UIDatePicker) {
        if allDaySwitch.on {
            endTimeLabel.text = EventDetailViewController.stringFromDate(sender.date)
        } else {
            endTimeLabel.text = EventDetailViewController.stringFromDatetime(sender.date)
        }
        repeatEndPicker.minimumDate = sender.date
        repeatEndDidChange(repeatEndPicker)
    }
    
    @IBAction func repeatEndDidChange(sender: UIDatePicker) {
        repeatEndLabel.text = EventDetailViewController.stringFromDate(sender.date)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        EventManager.sharedInstance.editCustomEvent(customEvent) { event in
            if self.allDaySwitch.on {
                event.duration = Event.Duration.AllDay.rawValue
            } else {
                event.duration = Event.Duration.PartialTime.rawValue
            }
            // TODO: Category / Tags not set
            event.category = Event.Category.Activity.rawValue
            event.tags = ""
            event.name = self.titleField.text
            event.place = self.placeField.text
            event.start = self.startTimePicker.date
            event.end = self.endTimePicker.date
            event.repeatType = self.repeatTypeLabel.text
            event.repeatEnd = self.repeatEndPicker.date
            event.hasReminder = self.reminderSwitch.on
            event.notes = self.notesTextView.text
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
