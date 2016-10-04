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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var flag = true
        for (index, hw) in homeworks.enumerate() {
            if hw.deadline >= NSDate() {
                tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .Top, animated: true)
                flag = false
                break
            }
        }
        if flag && homeworks.count > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: homeworks.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeworks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Homework") as! HomeworkCell
        let hw = homeworks[indexPath.row]
        let courseName = MobileManager.sharedInstance.courseNameWithIdentifier(hw.courseEvent!.identifier!)
        cell.nameLabel.text = "\(hw.name!)（\(courseName)）"
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
