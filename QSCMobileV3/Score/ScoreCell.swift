//
//  ScoreCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-08-09.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import GaugeKit

class ScoreCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gauge: Gauge!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gauge.type = .line
        gauge.startColor = UIColor.white
        gauge.endColor = UIColor.white
        gauge.maxValue = 5.0
        gauge.shadowRadius = 1
    }
    
}
