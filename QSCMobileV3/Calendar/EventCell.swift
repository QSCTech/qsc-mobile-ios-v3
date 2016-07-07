//
//  EventCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-05.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .DisclosureIndicator
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var lineView: UIImageView!
    
}
