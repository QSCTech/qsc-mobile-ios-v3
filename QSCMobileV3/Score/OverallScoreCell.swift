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
    @IBOutlet weak var auxKeyLabel1: UILabel!
    @IBOutlet weak var auxValueLabel1: UILabel!
    @IBOutlet weak var auxKeyLabel2: UILabel!
    @IBOutlet weak var auxValueLabel2: UILabel!
    @IBOutlet weak var totalCreditView: UIView!
    @IBOutlet weak var averageGradeView: UIView!
    @IBOutlet weak var overseaGradeView: UIView!
    @IBOutlet weak var averageScoreView: UIView!
    
    func hideAll() {
        averageGradeLabel.text = "-"
        totalCreditLabel.text = "-"
        auxValueLabel1.text = "-"
        auxValueLabel2.text = "-"
    }
    
}
