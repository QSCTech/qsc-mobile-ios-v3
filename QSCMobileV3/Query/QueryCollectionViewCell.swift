//
//  QueryCollectionViewCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-08-28.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class QueryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconLabel.layer.cornerRadius = 19
        iconLabel.clipsToBounds = true
    }
    
}
