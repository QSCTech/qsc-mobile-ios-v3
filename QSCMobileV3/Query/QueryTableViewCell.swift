//
//  QueryTableViewCell.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-08-28.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit

private let itemWidth = CGFloat(60)
private let itemHeight = CGFloat(80)
private let sectionInset = CGFloat(10)

class QueryTableViewCell: UITableViewCell {
    
    let contentSize = CGSize(width: UIScreen.main.bounds.width, height: itemHeight)
    
    var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        let number = CGFloat(QueryCollectionViewDelegate.number)
        layout.minimumInteritemSpacing = max((UIScreen.main.bounds.width - 2 * sectionInset - number * itemWidth) / (number - 1), 0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: sectionInset, bottom: 0, right: sectionInset)
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
