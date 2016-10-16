//
//  HomeworkListViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-10-02.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class HomeworkListViewController: UITableViewController {
    
    init() {
        super.init(nibName: "HomeworkListViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var homeworks = [Homework]()
    
    func reloadData() {
        homeworks = EventManager.sharedInstance.allHomeworks
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "作业一览"
        tableView.registerNib(UINib(nibName: "HomeworkCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Homework")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeworks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Homework") as! HomeworkCell
        let hw = homeworks[indexPath.row]
        cell.nameLabel.text = hw.name
        cell.courseLabel.text = MobileManager.sharedInstance.courseNameWithIdentifier(hw.courseEvent!.identifier!)
        cell.timeLabel.text = hw.deadline!.stringOfDatetime
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let sb = UIStoryboard(name: "Homework", bundle: NSBundle.mainBundle())
        let nc = sb.instantiateInitialViewController() as! UINavigationController
        (nc.topViewController as! HomeworkViewController).homework = homeworks[indexPath.row]
        presentViewController(nc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Destructive, title: "删除") { action, indexPath in
            EventManager.sharedInstance.removeHomework(self.homeworks[indexPath.row])
            self.reloadData()
        }
        return [delete]
    }
    
}
