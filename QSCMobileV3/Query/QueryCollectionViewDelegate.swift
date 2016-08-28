//
//  QueryCollectionViewDelegate.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-08-28.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class QueryCollectionViewDelegate: NSObject {
    
    var viewController: UIViewController!
    
    private let titles = ["校车", "课程", "考试"]
    private let icons = ["\u{f207}", "\u{f02d}", "\u{f040}"]
    private let colors = [UIColor(red: 0.498, green: 0.831, blue: 0.745, alpha: 1.0), QSCColor.course, QSCColor.exam]
    
}

extension QueryCollectionViewDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! QueryCollectionViewCell
        cell.iconLabel.text = icons[indexPath.row]
        cell.iconLabel.backgroundColor = colors[indexPath.row]
        cell.titleLabel.text = titles[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
            let vc = JwbinfosysLoginViewController()
            viewController.presentViewController(vc, animated: true, completion: nil)
        } else {
            switch indexPath.row {
            case 0:
                let vc = BusViewController()
                viewController.presentViewController(vc, animated: true, completion: nil)
            default:
                let storyboard = UIStoryboard(name: "QueryList", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! SemesterListViewController
                vc.source = indexPath.row == 1 ? .Course : .Exam
                viewController.showViewController(vc, sender: nil)
            }
        }
    }
    
}
