//
//  BusViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-21.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CoreActionSheetPicker
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
        return cell
    }
    
}
