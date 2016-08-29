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
        super.init(nibName: "BusViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerNib(UINib(nibName: "BusCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Bus")
        
        campusDidChange()
        weekendSwitch.on = isWeekend
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromButon: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var weekendSwitch: UISwitch!
    
    let campuses = ["紫金港", "玉泉", "西溪", "之江", "华家池"]
    
    var fromIndex = groupDefaults.integerForKey(CampusFromIndexKey)
    var toIndex = groupDefaults.integerForKey(CampusToIndexKey)
    var isWeekend = NSCalendar.currentCalendar().isDateInWeekend(NSDate())
    var schoolBus: SchoolBus!
    
    func campusDidChange() {
        fromButon.setTitle(campuses[fromIndex], forState: .Normal)
        toButton.setTitle(campuses[toIndex], forState: .Normal)
        schoolBus = SchoolBus(from: campuses[fromIndex], to: campuses[toIndex], isWeekend: isWeekend)
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
        
        groupDefaults.setInteger(fromIndex, forKey: CampusFromIndexKey)
        groupDefaults.setInteger(toIndex, forKey: CampusToIndexKey)
    }
    
    @IBAction func selectCampuses(sender: UIButton) {
        let picker = ActionSheetMultipleStringPicker(title: "选择校区", rows: [campuses, campuses], initialSelection: [fromIndex, toIndex], doneBlock: { picker, indexes, values in
            if let indexes = indexes as? [Int] {
                self.fromIndex = indexes[0]
                self.toIndex = indexes[1]
                self.campusDidChange()
            }
        }, cancelBlock: nil, origin: sender)
        picker.hideCancel = true
        picker.showActionSheetPicker()
    }
    
    @IBAction func exchangeCampuses(sender: UIButton) {
        swap(&fromIndex, &toIndex)
        campusDidChange()
    }
    
    @IBAction func weekendModeDidChange(sender: UISwitch) {
        isWeekend = sender.on
        campusDidChange()
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension BusViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolBus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Bus") as! BusCell
        cell.nameLabel.text = schoolBus.busName(indexPath.row)
        cell.timeLabel.text = schoolBus.fromTime(indexPath.row) + " - " + schoolBus.toTime(indexPath.row)
        cell.noteLabel.text = schoolBus.busNote(indexPath.row)
        cell.noteIcon.hidden = cell.noteLabel.text!.isEmpty
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.whiteColor()
            cell.plusButton.setImage(UIImage(named: "PlusGray"), forState: .Normal)
        } else {
            cell.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1.0)
            cell.plusButton.setImage(UIImage(named: "PlusWhite"), forState: .Normal)
        }
        cell.plusButton.setTitle(String(indexPath.row), forState: .Normal)
        cell.plusButton.addTarget(self, action: #selector(addEvent), forControlEvents: .TouchUpInside)
        return cell
    }
    
    func addEvent(sender: UIButton) {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        let index = Int(sender.currentTitle!)!
        let from = schoolBus.fromTime(index) != "*" ? schoolBus.fromTime(index) : schoolBus.toTime(index)
        let to = schoolBus.toTime(index) != "*" ? schoolBus.toTime(index) : schoolBus.fromTime(index)
        var fromDate: NSDate?
        var toDate: NSDate?
        if let from = formatter.dateFromString(from), to = formatter.dateFromString(to) {
            let calendar = NSCalendar.currentCalendar()
            let dateComps = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
            
            let fromComps = calendar.components([.Hour, .Minute], fromDate: from)
            dateComps.hour = fromComps.hour
            dateComps.minute = fromComps.minute
            fromDate = calendar.dateFromComponents(dateComps)
            
            let toComps = calendar.components([.Hour, .Minute], fromDate: to)
            dateComps.hour = toComps.hour
            dateComps.minute = toComps.minute
            toDate = calendar.dateFromComponents(dateComps)
        }
        
        let eventManager = EventManager.sharedInstance
        let event = eventManager.newCustomEvent
        event.category = Event.Category.Activity.rawValue
        event.name = "乘坐" + schoolBus.busName(index)
        event.notes = schoolBus.busNote(index)
        event.repeatType = "永不"
        event.repeatEnd = NSDate()
        event.notification = 0
        event.sponsor = "浙江大学"
        event.tags = ""
        if let fromDate = fromDate, toDate = toDate {
            event.duration = Event.Duration.PartialTime.rawValue
            event.start = fromDate
            event.end = toDate
        } else {
            event.duration = Event.Duration.AllDay.rawValue
            event.start = NSDate()
            event.end = NSDate()
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
        SVProgressHUD.showSuccessWithStatus("已添加到今日日程")
    }
    
}
