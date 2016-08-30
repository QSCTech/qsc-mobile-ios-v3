//
//  EventEditViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-19.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
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
    @IBOutlet weak var allDayCell: UITableViewCell!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var repeatTypeLabel: UILabel!
    @IBOutlet weak var repeatEndLabel: UILabel!
    @IBOutlet weak var repeatEndPicker: UIDatePicker!
    @IBOutlet weak var notificationCell: UITableViewCell!
    @IBOutlet weak var notesTextView: UITextView!
    
    var allDaySwitch: UISwitch!
    var notificationSwitch: UISwitch!
    
    // MARK: - View controller override
    
    private let eventManager = EventManager.sharedInstance
    private let currentCalendar = NSCalendar.currentCalendar()
    
    var customEvent: CustomEvent?
    var selectedDate: NSDate?
    
    var eventCategory: Event.Category {
        return Event.Category(rawValue: customEvent!.category!.integerValue)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allDaySwitch = UISwitch()
        allDaySwitch.addTarget(self, action: #selector(allDaySwitchDidChange), forControlEvents: .ValueChanged)
        allDaySwitch.on = false
        allDaySwitch.onTintColor = QSCColor.theme
        allDayCell.accessoryView = allDaySwitch
        notificationSwitch = UISwitch()
        notificationSwitch.on = true
        notificationSwitch.onTintColor = QSCColor.theme
        notificationCell.accessoryView = notificationSwitch
        
        if let event = customEvent {
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
            notificationSwitch.on = (event.notification!.integerValue >= 0)
            notesTextView.text = event.notes
        } else {
            customEvent = eventManager.newCustomEvent
            customEvent!.category = Event.Category.Todo.rawValue
            
            startTimePicker.date = selectedDate!
            endTimePicker.date = selectedDate!
            repeatEndPicker.date = selectedDate!
        }
        startTimeDidChange(startTimePicker)
        
        let items = [Event.Category.Lesson.name, Event.Category.Quiz.name, Event.Category.Activity.name, Event.Category.Todo.name]
        if eventCategory.rawValue - 2 < items.count {
            let menuView = BTNavigationDropdownMenu(title: items[eventCategory.rawValue - 2], items: items)
            menuView.didSelectItemAtIndexHandler = { index in
                self.customEvent!.category = index + 2
                self.navigationController?.navigationBar.backgroundColor = QSCColor.category(self.eventCategory)
            }
            menuView.arrowTintColor = UIColor.blackColor()
            menuView.cellBackgroundColor = UIColor.darkGrayColor()
            menuView.cellSeparatorColor = UIColor.darkGrayColor()
            menuView.cellTextLabelColor = UIColor.whiteColor()
            menuView.cellTextLabelAlignment = .Center
            menuView.cellHeight = 44
            menuView.checkMarkImage = nil
            navigationItem.titleView = menuView
        } else {
            navigationItem.title = eventCategory.name
        }
        navigationController?.navigationBar.backgroundColor = QSCColor.category(eventCategory)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        hideStartPicker()
        hideEndPicker()
        hideRepeatPicker()
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
            reloadRowFor(Time.StartPicker)
            if startPickerHeight > 0 {
                startTimeLabel.textColor = QSCColor.theme
                hideEndPicker()
                hideRepeatPicker()
            } else {
                startTimeLabel.textColor = QSCColor.detailText
            }
        case Time.EndTime.rawValue:
            endPickerHeight = pickerHeight - endPickerHeight
            reloadRowFor(Time.EndPicker)
            if endPickerHeight > 0 {
                endTimeLabel.textColor = QSCColor.theme
                hideStartPicker()
                hideRepeatPicker()
            } else {
                endTimeLabel.textColor = QSCColor.detailText
            }
        case Time.RepeatEnd.rawValue:
            repeatPickerHeight = pickerHeight - repeatPickerHeight
            if repeatPickerHeight > 0 {
                repeatEndLabel.textColor = QSCColor.theme
                hideStartPicker()
                hideEndPicker()
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
    
    func hideStartPicker() {
        if startPickerHeight > 0 {
            startPickerHeight = 0
            startTimeLabel.textColor = QSCColor.detailText
            reloadRowFor(Time.StartPicker)
        }
    }
    
    func hideEndPicker() {
        if endPickerHeight > 0 {
            endPickerHeight = 0
            endTimeLabel.textColor = QSCColor.detailText
            reloadRowFor(Time.EndPicker)
        }
    }
    
    func hideRepeatPicker() {
        if repeatPickerHeight > 0 {
            repeatPickerHeight = 0
            repeatEndLabel.textColor = QSCColor.detailText
            reloadRowFor(Time.RepeatPicker)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func editingDidBegin(sender: AnyObject) {
        hideStartPicker()
        hideEndPicker()
        hideRepeatPicker()
    }
    
    @IBAction func titleDidChange(sender: UITextField) {
        if sender.text!.isEmpty {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
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
        } else if currentCalendar.isDate(startTimePicker.date, inSameDayAsDate: endTimePicker.date) {
            endTimeLabel.text = EventDetailViewController.stringFromTime(sender.date)
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
        (navigationItem.titleView as? BTNavigationDropdownMenu)?.hide()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        customEvent!.name = titleField.text
        customEvent!.place = placeField.text
        if allDaySwitch.on {
            customEvent!.duration = Event.Duration.AllDay.rawValue
        } else {
            customEvent!.duration = Event.Duration.PartialTime.rawValue
        }
        customEvent!.start = startTimePicker.date
        customEvent!.end = endTimePicker.date
        customEvent!.repeatType = repeatTypeLabel.text
        customEvent!.repeatEnd = repeatEndPicker.date
        if notificationSwitch.on {
            customEvent!.notification = 0
        } else {
            customEvent!.notification = -1
        }
        customEvent!.notes = notesTextView.text
        // TODO: To implement tags
        customEvent!.tags = ""
        eventManager.save()
        
        (navigationItem.titleView as? BTNavigationDropdownMenu)?.hide()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func allDaySwitchDidChange(sender: UISwitch) {
        if sender.on {
            startTimePicker.datePickerMode = .Date
            endTimePicker.datePickerMode = .Date
            startTimeLabel.text = EventDetailViewController.stringFromDate(startTimePicker.date)
            endTimeLabel.text = EventDetailViewController.stringFromDate(endTimePicker.date)
        } else {
            startTimePicker.datePickerMode = .DateAndTime
            endTimePicker.datePickerMode = .DateAndTime
            startTimeLabel.text = EventDetailViewController.stringFromDatetime(startTimePicker.date)
            if currentCalendar.isDate(startTimePicker.date, inSameDayAsDate: endTimePicker.date) {
                endTimeLabel.text = EventDetailViewController.stringFromTime(endTimePicker.date)
            } else {
                endTimeLabel.text = EventDetailViewController.stringFromDatetime(endTimePicker.date)
            }
        }
    }
    
}
