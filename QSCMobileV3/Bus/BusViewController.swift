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
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromButon: UIButton!
    @IBOutlet weak var toButton: UIButton!
    
    let campuses = ["紫金港", "玉泉", "西溪", "之江", "华家池"]
    
    var fromIndex = 0
    var toIndex = 1
    var schoolBus = SchoolBus(from: "紫金港", to: "玉泉", isWeekend: false)
    
    func campusDidChange() {
        fromButon.setTitle(campuses[fromIndex], forState: .Normal)
        toButton.setTitle(campuses[toIndex], forState: .Normal)
        // FIXME: isWeekend?
        schoolBus = SchoolBus(from: campuses[fromIndex], to: campuses[toIndex], isWeekend: false)
        tableView.reloadData()
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
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension BusViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolBus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.textLabel!.text = schoolBus.busName(indexPath.row)
        cell.detailTextLabel!.text = schoolBus.fromTime(indexPath.row) + " - " + schoolBus.toTime(indexPath.row)
        return cell
    }
    
}
