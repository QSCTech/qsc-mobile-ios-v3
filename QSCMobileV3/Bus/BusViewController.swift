//
//  BusViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-21.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import CoreActionSheetPicker

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
    
    func campusDidChange() {
        fromButon.setTitle(campuses[fromIndex], forState: .Normal)
        toButton.setTitle(campuses[toIndex], forState: .Normal)
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
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
