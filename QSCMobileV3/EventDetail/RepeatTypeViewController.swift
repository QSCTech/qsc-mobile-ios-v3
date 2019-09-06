//
//  RepeatTypeViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-05-20.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class RepeatTypeViewController: UITableViewController {
    
    var eventEditViewController: EventEditViewController!
    var selectedCell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for cell in tableView.visibleCells {
            if cell.textLabel!.text == eventEditViewController.repeatTypeLabel.text {
                selectedCell = cell
                cell.accessoryType = .checkmark
            }
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCell.accessoryType = .none
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        
        let text = cell.textLabel!.text!
        eventEditViewController.repeatTypeLabel.text = text
        eventEditViewController.changeRepeatType(text)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
}
