//
//  OverallScoreCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-12.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class OverallScoreCell: UITableViewCell {
    
    @IBOutlet weak var totalCreditLabel: UILabel!
    @IBOutlet weak var averageGradeLabel: UILabel!
    @IBOutlet weak var fourPointLabel: UILabel!
    @IBOutlet weak var hundredPointLabel: UILabel!
    
    func hideAll() {
        averageGradeLabel.text = "-"
        totalCreditLabel.text = "-"
        fourPointLabel.text = "-"
        hundredPointLabel.text = "-"
    }
    
}
