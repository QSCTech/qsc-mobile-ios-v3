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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "校车"
    }
    
    let campuses = ["紫金港", "玉泉", "西溪", "之江", "华家池"]
    
    @IBAction func selectCampuses(sender: UIButton) {
        let picker = ActionSheetMultipleStringPicker(title: "选择校区", rows: [campuses, campuses], initialSelection: [0, 1], doneBlock: { picker, indexes, values in
            print(values)
            if let values = values as? [String] {
                self.fromLabel.text = values[0]
                self.toLabel.text = values[1]
            }
        }, cancelBlock: nil, origin: sender)
        picker.hideCancel = true
        picker.showActionSheetPicker()
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
