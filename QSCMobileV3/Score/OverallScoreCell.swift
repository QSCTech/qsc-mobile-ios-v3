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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let statistics = MobileManager.sharedInstance.statistics
        averageGradeLabel.text = String(format: "%.2f", statistics.averageGrade!.floatValue)
        totalCreditLabel.text = statistics.totalCredit!.stringValue
        majorGradeLabel.text = String(format: "%.2f", statistics.majorGrade!.floatValue)
        majorCreditLabel.text = statistics.majorCredit!.stringValue
    }
    
}
