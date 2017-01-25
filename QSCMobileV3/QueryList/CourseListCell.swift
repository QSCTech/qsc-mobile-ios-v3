//
//  CourseListCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-10.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class CourseListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let bgColor = dotView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        dotView.backgroundColor = bgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let bgColor = dotView.backgroundColor
        super.setSelected(selected, animated: animated)
        dotView.backgroundColor = bgColor
    }
    
}
