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
        super.init(nibName: "HomeworkListViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var homeworks = [Homework]()
    
    func reloadData() {
        homeworks = EventManager.sharedInstance.allHomeworks
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "作业一览"
        tableView.register(UINib(nibName: "HomeworkCell", bundle: Bundle.main), forCellReuseIdentifier: "Homework")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeworks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Homework") as! HomeworkCell
        let hw = homeworks[indexPath.row]
        if hw.isFinished!.boolValue {
            cell.dotView.isHidden = true
            cell.nameLabel.attributedText = NSAttributedString(string: hw.name!, attributes: [NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue, NSAttributedStringKey.baselineOffset: 0])
        } else {
            cell.dotView.isHidden = false
            cell.nameLabel.text = hw.name
        }
        cell.courseLabel.text = MobileManager.sharedInstance.courseNameWithIdentifier(hw.courseEvent!.identifier!)
        cell.timeLabel.text = hw.deadline!.stringOfDatetime
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sb = UIStoryboard(name: "Homework", bundle: Bundle.main)
        let nc = sb.instantiateInitialViewController() as! UINavigationController
        (nc.topViewController as! HomeworkViewController).homework = homeworks[indexPath.row]
        present(nc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "删除") { action, indexPath in
            EventManager.sharedInstance.removeHomework(self.homeworks[indexPath.row])
            self.reloadData()
        }
        return [delete]
    }
    
}
