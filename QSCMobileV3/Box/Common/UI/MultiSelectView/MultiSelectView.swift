//
//  MultiSelectView.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/22.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit

class MultiSelectView: UIView {
    
    var callBack:(([Int]) -> ())!
    
    var items: [[String: String]] = []
    let itemHeight: CGFloat = 44
    
    var containerView: UIView!
    
    var tableView: UITableView!
    
    var navigationBarView: UIView!
    let navigationBarHeight: CGFloat = 50
    
    var titleLabel: UILabel!
    
    var separatorLineForNavigationBarView: UIView!
    let separatorLineForNavigationBarViewHeight: CGFloat = 1
    
    var buttonBarView: UIView!
    let buttonBarHeight: CGFloat = 45
    
    var separatorLineForButtonBarView: UIView!
    let separatorLineForButtonBarViewHeight: CGFloat = 1
    
    var doneButton: UIButton!
    var cancelButton: UIButton!
    
    var separatorLineForButtons: UIView!
    let separatorLineForButtonsWidth: CGFloat = 1
    
    init(superView: UIView, title: String, width: CGFloat, height: CGFloat, offsetY: CGFloat, shadow: Bool) {
        super.init(frame: CGRect.zero)
        
        isHidden = true
        if shadow {
            backgroundColor = BoxColor.shadow
        } else {
            backgroundColor = UIColor.clear
        }
        superView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: superView.bounds.width))
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: superView.bounds.height))
        superView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0))
        superView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: height + navigationBarHeight + separatorLineForNavigationBarViewHeight + separatorLineForButtonsWidth + buttonBarHeight))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: offsetY))
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5)
        tableView.isScrollEnabled = true
        tableView.backgroundColor = UIColor.white
        tableView.register(UINib(nibName: "MultiSelectViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addConstraint(NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        tableView.addConstraint(NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: height))
        containerView.addConstraint(NSLayoutConstraint(item: tableView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: navigationBarHeight + separatorLineForNavigationBarViewHeight))
        
        navigationBarView = UIView()
        navigationBarView.backgroundColor = UIColor.white
        containerView.addSubview(navigationBarView)
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarView.addConstraint(NSLayoutConstraint(item: navigationBarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        navigationBarView.addConstraint(NSLayoutConstraint(item: navigationBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: navigationBarHeight))
        containerView.addConstraint(NSLayoutConstraint(item: navigationBarView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: navigationBarView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0))
        
        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        navigationBarView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: navigationBarHeight))
        navigationBarView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: navigationBarView, attribute: .centerX, multiplier: 1, constant: 0))
        navigationBarView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: navigationBarView, attribute: .centerY, multiplier: 1, constant: 0))
        
        separatorLineForNavigationBarView = UIView()
        separatorLineForNavigationBarView.backgroundColor = BoxColor.gray
        containerView.addSubview(separatorLineForNavigationBarView)
        separatorLineForNavigationBarView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineForNavigationBarView.addConstraint(NSLayoutConstraint(item: separatorLineForNavigationBarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        separatorLineForNavigationBarView.addConstraint(NSLayoutConstraint(item: separatorLineForNavigationBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: separatorLineForNavigationBarViewHeight))
        containerView.addConstraint(NSLayoutConstraint(item: separatorLineForNavigationBarView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: separatorLineForNavigationBarView, attribute: .top, relatedBy: .equal, toItem: navigationBarView, attribute: .bottom, multiplier: 1, constant: 0))
        
        buttonBarView = UIView()
        buttonBarView.backgroundColor = UIColor.white
        containerView.addSubview(buttonBarView)
        buttonBarView.translatesAutoresizingMaskIntoConstraints = false
        buttonBarView.addConstraint(NSLayoutConstraint(item: buttonBarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        buttonBarView.addConstraint(NSLayoutConstraint(item: buttonBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: buttonBarHeight))
        containerView.addConstraint(NSLayoutConstraint(item: buttonBarView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: buttonBarView, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1, constant: separatorLineForButtonBarViewHeight))
        
        separatorLineForButtonBarView = UIView()
        separatorLineForButtonBarView.backgroundColor = BoxColor.gray
        containerView.addSubview(separatorLineForButtonBarView)
        separatorLineForButtonBarView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineForButtonBarView.addConstraint(NSLayoutConstraint(item: separatorLineForButtonBarView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width))
        separatorLineForButtonBarView.addConstraint(NSLayoutConstraint(item: separatorLineForButtonBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: separatorLineForButtonBarViewHeight))
        containerView.addConstraint(NSLayoutConstraint(item: separatorLineForButtonBarView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: separatorLineForButtonBarView, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .bottom, multiplier: 1, constant: 0))
        
        doneButton = UIButton(type: .system)
        doneButton.setTitle("确定", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped(button:)), for: .touchDown)
        buttonBarView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: buttonBarHeight - 5))
        doneButton.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width / 2))
        buttonBarView.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .right, relatedBy: .equal, toItem: buttonBarView, attribute: .right, multiplier: 1.0, constant: 0))
        buttonBarView.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: buttonBarView, attribute: .top, multiplier: 1.0, constant: 5))
        
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(button:)), for: .touchDown)
        buttonBarView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: buttonBarHeight - 5))
        cancelButton.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: width / 2))
        buttonBarView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: buttonBarView, attribute: .left, multiplier: 1.0, constant: 0))
        buttonBarView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: buttonBarView, attribute: .top, multiplier: 1.0, constant: 5))
        
        separatorLineForButtons = UIView()
        separatorLineForButtons.backgroundColor = BoxColor.gray
        buttonBarView.addSubview(separatorLineForButtons)
        separatorLineForButtons.translatesAutoresizingMaskIntoConstraints = false
        separatorLineForButtons.addConstraint(NSLayoutConstraint(item: separatorLineForButtons, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: separatorLineForButtonsWidth))
        separatorLineForButtons.addConstraint(NSLayoutConstraint(item: separatorLineForButtons, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: buttonBarHeight - 5))
        buttonBarView.addConstraint(NSLayoutConstraint(item: separatorLineForButtons, attribute: .centerX, relatedBy: .equal, toItem: buttonBarView, attribute: .centerX, multiplier: 1, constant: 0))
        buttonBarView.addConstraint(NSLayoutConstraint(item: separatorLineForButtons, attribute: .top, relatedBy: .equal, toItem: buttonBarView, attribute: .top, multiplier: 1, constant: 5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setItems(items: [[String: String]]) {
        self.items = items
        tableView.reloadData()
    }
    
    @objc func doneButtonTapped(button: UIButton) {
        isHidden = true
        var multiSelect: [Int] = []
        for (index, item) in items.enumerated() {
            if item["select"] == "true" {
                multiSelect.append(index)
            }
        }
        if callBack != nil {
            callBack(multiSelect)
        }
    }
    
    @objc func cancelButtonTapped(button: UIButton) {
        isHidden = true
        if callBack != nil {
            callBack([])
        }
    }
    
}

extension MultiSelectView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MultiSelectViewCell
        cell.icon.image = UIImage(named: items[indexPath.row]["icon"]!)
        cell.label.text = items[indexPath.row]["text"]
        if items[indexPath.row]["select"] == "true" {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if items[indexPath.row]["select"] == "true" {
            items[indexPath.row]["select"] = "false"
        } else {
            items[indexPath.row]["select"] = "true"
        }
        tableView.reloadData()
    }
    
}
