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
    
    @IBOutlet weak var averageGradeLabel: UILabel!
    @IBOutlet weak var totalCreditLabel: UILabel!
    @IBOutlet weak var majorGradeLabel: UILabel!
    @IBOutlet weak var majorCreditLabel: UILabel!
    
    func hideAll() {
        averageGradeLabel.text = "-"
        totalCreditLabel.text = "-"
        majorGradeLabel.text = "-"
        majorCreditLabel.text = "-"
    }
    
}
