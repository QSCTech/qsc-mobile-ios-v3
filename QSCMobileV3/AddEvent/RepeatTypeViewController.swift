//
//  RepeatTypeViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-20.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class RepeatTypeViewController: UITableViewController {
    
    var addEventViewController: AddEventViewController?
    
    var selectedCell: UITableViewCell?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for cell in tableView.visibleCells {
            if cell.textLabel!.text == addEventViewController!.repeatTypeLabel!.text {
                selectedCell = cell
                cell.accessoryType = .Checkmark
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedCell!.accessoryType = .None
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.accessoryType = .Checkmark
        
        let text = cell.textLabel!.text!
        addEventViewController!.repeatTypeLabel!.text = text
        addEventViewController!.changeRepeatType(text)
        
        navigationController?.popViewControllerAnimated(true)
    }
    
}
