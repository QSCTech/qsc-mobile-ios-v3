//
//  DropDownMenuView.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit

class DropDownMenuView: UIButton {
    
    var selectCallBack: ((Int) -> Void)?
    var cancelCallBack: (() -> Void)?
    
    var items = [[String: String]]()
    let itemHeight = CGFloat(44)
    
    var pointerImageView: UIImageView!
    var tableView: UITableView!
    
    init(items: [[String: String]], superView: UIView, width: CGFloat, pointerX: CGFloat, pointerY: CGFloat, menuX: CGFloat, shadow: Bool) {
        super.init(frame: superView.bounds)
        
        self.items = items
        backgroundColor = shadow ? BoxColor.shadow : UIColor.clear
        addTarget(self, action: #selector(otherAreaTapped), for: .touchDown)
        
        pointerImageView = UIImageView(frame: CGRect(x: pointerX, y: pointerY, width: 23, height: 11))
        pointerImageView.image = UIImage(named: "MenuPointer")
        addSubview(pointerImageView)
        
        tableView = UITableView(frame: CGRect(x: menuX, y: pointerY + 11, width: width, height: itemHeight * CGFloat(items.count) - 1))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = UIImageView(image: UIImage(named: "MenuBackground"))
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 5
        tableView.register(UINib(nibName: "DropDownMenuCell", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        addSubview(tableView)
        
        isHidden = true
        
        superView.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func otherAreaTapped() {
        cancelCallBack?()
    }
    
}

extension DropDownMenuView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DropDownMenuCell
        cell.icon.image = UIImage(named: items[indexPath.row]["icon"]!)
        cell.label.text = items[indexPath.row]["text"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        isHidden = true
        selectCallBack?(indexPath.row)
    }
    
}
