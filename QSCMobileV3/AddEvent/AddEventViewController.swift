//
//  AddEventViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-19.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class AddEventViewController: UITableViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimeLabel.text = datetimeFormatter.stringFromDate(startTimePicker.date)
        endTimeLabel.text = datetimeFormatter.stringFromDate(endTimePicker.date)
        repeatEndLabel.text = dateFormatter.stringFromDate(repeatEndPicker.date)
        
        endTimePicker.minimumDate = startTimePicker.date
        repeatEndPicker.minimumDate = endTimePicker.date
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! RepeatTypeViewController
        vc.addEventViewController = self
    }
    
    // MARK: - Table view data delegate
    
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
            reloadRowFor(Time.StartPicker)
        case Time.EndTime.rawValue:
            endPickerHeight = pickerHeight - endPickerHeight
            reloadRowFor(Time.EndPicker)
        case Time.RepeatEnd.rawValue:
            repeatPickerHeight = pickerHeight - repeatPickerHeight
            reloadRowFor(Time.RepeatPicker)
        default:
            break
        }
    }
    
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
            startTimeLabel.text = dateFormatter.stringFromDate(startTimePicker.date)
            endTimeLabel.text = dateFormatter.stringFromDate(endTimePicker.date)
        } else {
            startTimePicker.datePickerMode = .DateAndTime
            endTimePicker.datePickerMode = .DateAndTime
            startTimeLabel.text = datetimeFormatter.stringFromDate(startTimePicker.date)
            endTimeLabel.text = datetimeFormatter.stringFromDate(endTimePicker.date)
        }
    }
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
    
    private let datetimeFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy年M月d日    HH:mm"
        return formatter
    }()
    
    func updatePicker(picker: UIDatePicker) -> Bool {
        if picker.date < picker.minimumDate {
            picker.date = picker.minimumDate!
            return true
        } else {
            return false
        }
    }
    
    @IBAction func startTimeDidChange(sender: UIDatePicker) {
        if allDaySwitch.on {
            startTimeLabel.text = dateFormatter.stringFromDate(sender.date)
        } else {
            startTimeLabel.text = datetimeFormatter.stringFromDate(sender.date)
        }
        endTimePicker.minimumDate = sender.date
        if updatePicker(endTimePicker) {
            endTimeDidChange(endTimePicker)
        }
    }
    
    @IBAction func endTimeDidChange(sender: UIDatePicker) {
        if allDaySwitch.on {
            endTimeLabel.text = dateFormatter.stringFromDate(sender.date)
        } else {
            endTimeLabel.text = datetimeFormatter.stringFromDate(sender.date)
        }
        repeatEndPicker.minimumDate = sender.date
        if updatePicker(repeatEndPicker) {
            repeatEndDidChange(repeatEndPicker)
        }
    }
    
    @IBAction func repeatEndDidChange(sender: UIDatePicker) {
        repeatEndLabel.text = dateFormatter.stringFromDate(sender.date)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        EventManager.sharedInstance.createCustomEvent { event in
            if self.allDaySwitch.on {
                event.duration = Event.Duration.AllDay.rawValue
            } else {
                event.duration = Event.Duration.PartialTime.rawValue
            }
            // TODO: Category / Tags not set
            event.category = Event.Category.Life.rawValue
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
