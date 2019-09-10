//
//  BusViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-21.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CoreActionSheetPicker
import SVProgressHUD
import QSCMobileKit

let CampusFromIndexKey = "CampusFromIndex"
let CampusToIndexKey = "CampusToIndex"

class BusViewController: UIViewController {
    
    init() {
        super.init(nibName: "BusViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(UINib(nibName: "BusCell", bundle: Bundle.main), forCellReuseIdentifier: "Bus")
        
        campusDidChange()
        weekendSwitch.isOn = isWeekend
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromButon: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var weekendSwitch: UISwitch!
    
    let campuses = ["紫金港", "玉泉", "西溪", "之江", "华家池"]
    
    var fromIndex = groupDefaults.integer(forKey: CampusFromIndexKey)
    var toIndex = groupDefaults.integer(forKey: CampusToIndexKey)
    var isWeekend = Calendar.current.isDateInWeekend(Date())
    var schoolBus: SchoolBus!
    
    func campusDidChange() {
        fromButon.setTitle(campuses[fromIndex], for: .normal)
        toButton.setTitle(campuses[toIndex], for: .normal)
        schoolBus = SchoolBus(from: campuses[fromIndex], to: campuses[toIndex], isWeekend: isWeekend)
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
        
        groupDefaults.set(fromIndex, forKey: CampusFromIndexKey)
        groupDefaults.set(toIndex, forKey: CampusToIndexKey)
    }
    
    @IBAction func selectCampuses(_ sender: UIButton) {
        let picker = ActionSheetMultipleStringPicker(title: "选择校区", rows: [campuses, campuses], initialSelection: [fromIndex, toIndex], doneBlock: { picker, indexes, values in
            if let indexes = indexes as? [Int] {
                self.fromIndex = indexes[0]
                self.toIndex = indexes[1]
                self.campusDidChange()
            }
        }, cancel: nil, origin: sender)!
        picker.hideCancel = true
        picker.show()
    }
    
    @IBAction func exchangeCampuses(_ sender: UIButton) {
        swap(&fromIndex, &toIndex)
        campusDidChange()
    }
    
    @IBAction func weekendModeDidChange(_ sender: UISwitch) {
        isWeekend = sender.isOn
        campusDidChange()
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
}

extension BusViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolBus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Bus") as! BusCell
        cell.nameLabel.text = schoolBus.busName(indexPath.row)
        cell.timeLabel.text = schoolBus.fromTime(indexPath.row) + " - " + schoolBus.toTime(indexPath.row)
        cell.noteLabel.text = schoolBus.busNote(indexPath.row)
        cell.noteIcon.isHidden = cell.noteLabel.text!.isEmpty
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
            cell.plusButton.setImage(UIImage(named: "PlusGray"), for: .normal)
        } else {
            cell.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1.0)
            cell.plusButton.setImage(UIImage(named: "PlusWhite"), for: .normal)
        }
        cell.plusButton.setTitle(String(indexPath.row), for: .normal)
        cell.plusButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)
        return cell
    }
    
    @objc func addEvent(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "HH:mm"
        let index = Int(sender.currentTitle!)!
        let from = schoolBus.fromTime(index) != "*" ? schoolBus.fromTime(index) : schoolBus.toTime(index)
        let to = schoolBus.toTime(index) != "*" ? schoolBus.toTime(index) : schoolBus.fromTime(index)
        var fromDate: Date?
        var toDate: Date?
        if let from = formatter.date(from: from), let to = formatter.date(from: to) {
            var dateComps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            
            let fromComps = Calendar.current.dateComponents([.hour, .minute], from: from)
            dateComps.hour = fromComps.hour
            dateComps.minute = fromComps.minute
            fromDate = Calendar.current.date(from: dateComps)
            
            let toComps = Calendar.current.dateComponents([.hour, .minute], from: to)
            dateComps.hour = toComps.hour
            dateComps.minute = toComps.minute
            toDate = Calendar.current.date(from: dateComps)
        }
        
        let eventManager = EventManager.sharedInstance
        let event = eventManager.newCustomEvent
        event.category = Event.Category.bus.rawValue as NSNumber
        event.name = "乘坐" + schoolBus.busName(index)
        event.notes = schoolBus.busNote(index)
        event.repeatType = "永不"
        event.repeatEnd = Date()
        event.notification = 900 // 15 minutes
        event.sponsor = "浙江大学"
        event.tags = ""
        if let fromDate = fromDate, let toDate = toDate {
            event.duration = Event.Duration.partialTime.rawValue as NSNumber
            event.start = fromDate
            event.end = toDate
        } else {
            event.duration = Event.Duration.allDay.rawValue as NSNumber
            event.start = Date()
            event.end = Date()
        }
        switch fromIndex {
        case 0:
            event.place = "紫金港校区"
        case 1:
            event.place = "玉泉校区教二南侧"
        case 2:
            event.place = "西溪校区南大门"
        case 3:
            event.place = "之江校区大门口"
        case 4:
            event.place = "华家池校区体育馆、新大门"
        default:
            event.place = ""
        }
        eventManager.save()
        
        EventEditViewController.addLocalNotification(event)
        
        NotificationCenter.default.post(name: .eventsModified, object: nil, userInfo: ["start": event.start!, "end": event.end!])
        SVProgressHUD.showSuccess(withStatus: "已添加到今日日程")
    }
    
}
