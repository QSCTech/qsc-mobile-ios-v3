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
    
    let titles = [
        "校车",
        "课表",
        "课程",
        "考试",
        "作业",
    ]
    let icons = [
        "\u{f207}",
        "\u{f073}",
        "\u{f02d}",
        "\u{f040}",
        "\u{f0c5}",
    ]
    let colors = [
        UIColor(red: 0.498, green: 0.831, blue: 0.745, alpha: 1.0),
        QSCColor.theme,
        QSCColor.course,
        QSCColor.exam,
        QSCColor.theme,
    ]
    
}

extension QueryCollectionViewDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! QueryCollectionViewCell
        cell.iconLabel.text = icons[indexPath.row]
        cell.iconLabel.backgroundColor = colors[indexPath.row]
        cell.titleLabel.text = titles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AccountManager.sharedInstance.currentAccountForJwbinfosys == nil {
            let vc = JwbinfosysLoginViewController()
            viewController.present(vc, animated: true)
        } else {
            switch indexPath.row {
            case 0:
                let vc = BusViewController()
                viewController.present(vc, animated: true)
            case 1:
                let vc = CurriculaViewController()
                vc.hidesBottomBarWhenPushed = true
                viewController.show(vc, sender: nil)
            case 4:
                let vc = HomeworkListViewController()
                vc.hidesBottomBarWhenPushed = true
                viewController.show(vc, sender: nil)
            default:
                let storyboard = UIStoryboard(name: "QueryList", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! SemesterListViewController
                vc.source = indexPath.row == 2 ? .course : .exam
                vc.hidesBottomBarWhenPushed = true
                viewController.show(vc, sender: nil)
            }
        }
    }
    
}
