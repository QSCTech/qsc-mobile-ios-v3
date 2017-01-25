//
//  HomeworkCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-10-02.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class HomeworkCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
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
