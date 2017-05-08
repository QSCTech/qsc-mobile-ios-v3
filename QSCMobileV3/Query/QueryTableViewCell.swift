//
//  QueryTableViewCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-08-28.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

class QueryTableViewCell: UITableViewCell {
    
    let contentSize = CGSize(width: UIScreen.main.bounds.width, height: 80)
    
    var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 80)
        layout.minimumInteritemSpacing = (UIScreen.main.bounds.width - 400) / 4 > 0 ? (UIScreen.main.bounds.width - 400) / 4 : 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        
        scrollView = UIScrollView()
        scrollView.contentSize = contentSize
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(collectionView)
        contentView.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
    }
    
}
