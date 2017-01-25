//
//  TableViewCell.swift
//  QSCMobileV3
//
//  Created by kingcyk on 2016/11/17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventPlace: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventType: UIView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let bgColor = eventType.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        eventType.backgroundColor = bgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let bgColor = eventType.backgroundColor
        super.setSelected(selected, animated: animated)
        eventType.backgroundColor = bgColor
    }
    
}
