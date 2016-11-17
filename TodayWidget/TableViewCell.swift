//
//  TableViewCell.swift
//  QSCMobileV3
//
//  Created by kingcyk on 2016/11/17.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet var startTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var eventName: UILabel!
    @IBOutlet var eventPlace: UILabel!
    @IBOutlet var eventTime: UILabel!
    @IBOutlet var eventType: UIView!
    
}
