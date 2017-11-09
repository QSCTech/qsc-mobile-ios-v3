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
    
    let timeSection = 1
    let notesSection = 2
    
    enum Time: Int {
        case allDay = 0
        case startTime
        case startPicker
        case endTime
        case endPicker
        case repeatType
        case repeatEnd
        case repeatPicker
        case notification
    }
    
    // MARK: - Cell heights
    
    let basicHeight = CGFloat(44)
    let pickerHeight = CGFloat(200)
    let notesHeight = CGFloat(150)
    
    var startPickerHeight = CGFloat(0)
    var endPickerHeight = CGFloat(0)
    var repeatEndHeight = CGFloat(0)
    var repeatPickerHeight = CGFloat(0)
    
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
    @IBOutlet weak var notificationTypeLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    var allDaySwitch: UISwitch!
    
    // MARK: - View controller override
    
    let eventManager = EventManager.sharedInstance
    
    var customEvent: CustomEvent?
    var selectedDate: Date? {
        didSet {
            selectedDate = selectedDate!.today
        }
    }
    
    var eventCategory: Event.Category {
        return Event.Category(rawValue: customEvent!.category!.intValue)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allDaySwitch = UISwitch()
        allDaySwitch.addTarget(self, action: #selector(allDaySwitchDidChange), for: .valueChanged)
        allDaySwitch.isOn = false
        allDaySwitch.onTintColor = QSCColor.theme
        allDayCell.accessoryView = allDaySwitch
        
        if let event = customEvent {
            titleField.text = event.name
            titleDidChange(titleField)
            placeField.text = event.place
            allDaySwitch.isOn = (event.duration!.intValue == Event.Duration.allDay.rawValue)
            allDaySwitchDidChange(allDaySwitch)
            startTimePicker.date = event.start!
            endTimePicker.date = event.end!
            repeatTypeLabel.text = event.repeatType
            changeRepeatType(event.repeatType!)
            repeatEndPicker.date = event.repeatEnd!
            notificationTypeLabel.text = event.notification!.stringFromNotificationType
            notesTextView.text = event.notes
            
            for notif in UIApplication.shared.scheduledLocalNotifications!.filter({ $0.userInfo!["objectID"] as! String == event.objectID.uriRepresentation().absoluteString }) {
                UIApplication.shared.cancelLocalNotification(notif)
            }
        } else {
            customEvent = eventManager.newCustomEvent
            customEvent!.category = Event.Category.todo.rawValue as NSNumber
            
            startTimePicker.date = selectedDate!
            endTimePicker.date = selectedDate!
            repeatEndPicker.date = selectedDate!.addingTimeInterval(31536000)
        }
        startTimeDidChange(startTimePicker)
        
        prepareDropDownMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideStartPicker()
        hideEndPicker()
        hideRepeatPicker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RepeatTypeViewController {
            vc.eventEditViewController = self
        } else if let vc = segue.destination as? NotificationTypeViewController {
            vc.eventEditViewController = self
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case timeSection:
            switch Time(rawValue: indexPath.row)! {
            case .startPicker:
                return startPickerHeight
            case .endPicker:
                return endPickerHeight
            case .repeatEnd:
                return repeatEndHeight
            case .repeatPicker:
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section != timeSection {
            return
        }
        switch Time(rawValue: indexPath.row)! {
        case .startTime:
            startPickerHeight = pickerHeight - startPickerHeight
            reloadRowFor(Time.startPicker)
            if startPickerHeight > 0 {
                startTimeLabel.textColor = QSCColor.theme
                hideEndPicker()
                hideRepeatPicker()
            } else {
                startTimeLabel.textColor = QSCColor.detailText
            }
        case .endTime:
            endPickerHeight = pickerHeight - endPickerHeight
            reloadRowFor(Time.endPicker)
            if endPickerHeight > 0 {
                endTimeLabel.textColor = QSCColor.theme
                hideStartPicker()
                hideRepeatPicker()
            } else {
                endTimeLabel.textColor = QSCColor.detailText
            }
        case .repeatEnd:
            repeatPickerHeight = pickerHeight - repeatPickerHeight
            if repeatPickerHeight > 0 {
                repeatEndLabel.textColor = QSCColor.theme
                hideStartPicker()
                hideEndPicker()
            } else {
                repeatEndLabel.textColor = QSCColor.detailText
            }
            reloadRowFor(Time.repeatPicker)
        default:
            break
        }
    }
    
    // MARK: - Reload row
    
    func reloadRowFor(_ row: Time) {
        let indexPath = IndexPath(row: row.rawValue, section: timeSection)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    func changeRepeatType(_ type: String) {
        if type == "永不" {
            repeatEndHeight = 0
            reloadRowFor(Time.repeatEnd)
        } else {
            repeatEndHeight = basicHeight
            reloadRowFor(Time.repeatEnd)
        }
    }
    
    func hideStartPicker() {
        if startPickerHeight > 0 {
            startPickerHeight = 0
            startTimeLabel.textColor = QSCColor.detailText
            reloadRowFor(Time.startPicker)
        }
    }
    
    func hideEndPicker() {
        if endPickerHeight > 0 {
            endPickerHeight = 0
            endTimeLabel.textColor = QSCColor.detailText
            reloadRowFor(Time.endPicker)
        }
    }
    
    func hideRepeatPicker() {
        if repeatPickerHeight > 0 {
            repeatPickerHeight = 0
            repeatEndLabel.textColor = QSCColor.detailText
            reloadRowFor(Time.repeatPicker)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func editingDidBegin(_ sender: AnyObject) {
        hideStartPicker()
        hideEndPicker()
        hideRepeatPicker()
    }
    
    @IBAction func titleDidChange(_ sender: UITextField) {
        if sender.text!.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func startTimeDidChange(_ sender: UIDatePicker) {
        if allDaySwitch.isOn {
            startTimeLabel.text = sender.date.stringOfDate
        } else {
            startTimeLabel.text = sender.date.stringOfDatetime
        }
        endTimePicker.minimumDate = sender.date
        endTimeDidChange(endTimePicker)
    }
    
    @IBAction func endTimeDidChange(_ sender: UIDatePicker) {
        if allDaySwitch.isOn {
            endTimeLabel.text = sender.date.stringOfDate
        } else if Calendar.current.isDate(startTimePicker.date, inSameDayAs: endTimePicker.date) {
            endTimeLabel.text = sender.date.stringOfTime
        } else {
            endTimeLabel.text = sender.date.stringOfDatetime
        }
        repeatEndPicker.minimumDate = sender.date
        repeatEndDidChange(repeatEndPicker)
    }
    
    @IBAction func repeatEndDidChange(_ sender: UIDatePicker) {
        repeatEndLabel.text = sender.date.stringOfDate
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        if customEvent!.name == nil {
            eventManager.removeCustomEvent(customEvent!)
        }
        
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        let started = customEvent!.start
        let ended = customEvent!.end
        let repeated = (customEvent!.notification ?? -1) >= 0
        
        customEvent!.name = titleField.text
        customEvent!.place = placeField.text
        if allDaySwitch.isOn {
            customEvent!.duration = Event.Duration.allDay.rawValue as NSNumber
        } else {
            customEvent!.duration = Event.Duration.partialTime.rawValue as NSNumber
        }
        customEvent!.start = startTimePicker.date
        customEvent!.end = endTimePicker.date
        customEvent!.repeatType = repeatTypeLabel.text
        customEvent!.repeatEnd = repeatEndPicker.date
        customEvent!.notification = notificationTypeLabel.text!.numberFromNotificationType as NSNumber
        customEvent!.notes = notesTextView.text
        // TODO: To implement tags
        customEvent!.tags = ""
        eventManager.save()
        
        if repeated || customEvent!.notification!.intValue >= 0 {
            NotificationCenter.default.post(name: .eventsModified, object: nil)
        } else {
            if let started = started, let ended = ended {
                NotificationCenter.default.post(name: .eventsModified, object: nil, userInfo: ["start": started, "end": ended])
            }
            NotificationCenter.default.post(name: .eventsModified, object: nil, userInfo: ["start": customEvent!.start!, "end": customEvent!.end!])
        }
        
        if customEvent!.notification!.intValue >= 0 {
            let notif = EventEditViewController.addLocalNotification(customEvent!)
            
            if customEvent!.repeatType != "永不" {
                let components: DateComponents
                switch customEvent!.repeatType! {
                case "每周", "每两周":
                    components = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: customEvent!.start!)
                case "每月":
                    components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: customEvent!.start!)
                default:
                    components = Calendar.current.dateComponents([.hour, .minute, .second], from: customEvent!.start!)
                }
                var flag = false
                Calendar.current.enumerateDates(startingAfter: customEvent!.start!, matching: components, matchingPolicy: .strict) { start, _, stop in
                    if start!.today > self.customEvent!.repeatEnd! {
                        stop = true
                        return
                    }
                    flag = !flag
                    if self.customEvent!.repeatType! == "每两周" && flag || start! < Date() {
                        return
                    }
                    let notif = notif.copy() as! UILocalNotification
                    notif.fireDate = start
                    UIApplication.shared.scheduleLocalNotification(notif)
                }
            }
        }
        
        dismiss(animated: true)
    }
    
    @objc func allDaySwitchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            startTimePicker.datePickerMode = .date
            endTimePicker.datePickerMode = .date
            startTimeLabel.text = startTimePicker.date.stringOfDate
            endTimeLabel.text = endTimePicker.date.stringOfDate
        } else {
            startTimePicker.datePickerMode = .dateAndTime
            endTimePicker.datePickerMode = .dateAndTime
            startTimeLabel.text = startTimePicker.date.stringOfDatetime
            if Calendar.current.isDate(startTimePicker.date, inSameDayAs: endTimePicker.date) {
                endTimeLabel.text = endTimePicker.date.stringOfTime
            } else {
                endTimeLabel.text = endTimePicker.date.stringOfDatetime
            }
        }
    }
    
    // MARK: - Local notifications
    
    @discardableResult static func addLocalNotification(_ event: CustomEvent) -> UILocalNotification {
        let notif = UILocalNotification()
        let time = event.notification == 0 ? "已" : "将于 " + event.notification!.stringFromNotificationType.replacingOccurrences(of: "前", with: "后")
        let place = event.place == "" ? "" : "在 " + event.place! + " "
        notif.alertBody = "「\(event.name!)」\(time)\(place)开始"
        notif.fireDate = event.start!.addingTimeInterval(-event.notification!.doubleValue)
        notif.soundName = UILocalNotificationDefaultSoundName
        notif.userInfo = ["objectID": event.objectID.uriRepresentation().absoluteString]
        if notif.fireDate! >= Date() {
            UIApplication.shared.scheduleLocalNotification(notif)
        }
        return notif
    }
    
    // MARK: - Drop-down Menu
    
    var dropDownMenu: DropDownMenuView!
    let dropDownItems = [
        ["text": Event.Category.lesson.name, "icon": "DotLesson"],
        ["text": Event.Category.quiz.name, "icon": "DotQuiz"],
        ["text": Event.Category.activity.name, "icon": "DotActivity"],
        ["text": Event.Category.todo.name, "icon": "DotTodo"],
    ]
    let dropDownArrow = "▾"
    let foldUpArrow   = "▴"
    
    func prepareDropDownMenu() {
        if eventCategory.rawValue - 2 < dropDownItems.count {
            let halfWidth = view.bounds.width / 2
            dropDownMenu = DropDownMenuView(items: dropDownItems, superView: view, width: 100, pointerX: halfWidth - 11, pointerY: 0, menuX: halfWidth - 50, shadow: true)
            dropDownMenu.selectCallBack = selectCallBack
            dropDownMenu.cancelCallBack = cancelCallBack
        }
        navigationItem.titleView = titleView
        selectCallBack(index: -1)
    }
    
    func selectCallBack(index: Int) {
        if index >= 0 {
            customEvent?.category = (index + 2) as NSNumber
        }
        titleView.text = "\(dropDownArrow)  \(eventCategory.name)"
        navigationController?.navigationBar.backgroundColor = QSCColor.category(self.eventCategory)
        dropDownMenu.isHidden = true
    }
    
    func cancelCallBack() {
        titleView.text = titleView.text!.replacingOccurrences(of: foldUpArrow, with: dropDownArrow)
        dropDownMenu.isHidden = true
    }
    
    lazy var titleView: UILabel = {
        let titleView = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        titleView.font = UIFont.boldSystemFont(ofSize: 18)
        titleView.textAlignment = .center
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleViewTapHandler)))
        return titleView
    }()
    
    @objc func titleViewTapHandler(_ sender: AnyObject?) {
        if titleView.text!.contains(dropDownArrow) {
            titleView.text = titleView.text!.replacingOccurrences(of: dropDownArrow, with: foldUpArrow)
            dropDownMenu.isHidden = false
        } else {
            cancelCallBack()
        }
    }
    
}
