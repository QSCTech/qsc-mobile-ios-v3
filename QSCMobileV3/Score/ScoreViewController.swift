//
//  ScoreViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-30.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class ScoreViewController: UIViewController {
    
    init() {
        super.init(nibName: "ScoreViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let mobileManager = MobileManager.sharedInstance
    
    let buttonWidth = CGFloat(100)
    let buttonHeight = CGFloat(48)
    
    var semesterScores = [SemesterScore]()
    var selectedIndex = 0
    var selectedScores = [Score]()
    
    @IBOutlet weak var semesterCreditLabel: UILabel!
    @IBOutlet weak var semesterGradeLabel: UILabel!
    @IBOutlet weak var totalCreditLabel: UILabel!
    @IBOutlet weak var averageGradeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let imageView = UIImageView(image: UIImage(named: "Triangle"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ScoreCell", bundle: Bundle.main), forCellReuseIdentifier: "Score")
        
        averageGradeLabel.text = String(format: "%.2f", mobileManager.statistics!.averageGrade!.floatValue)
        totalCreditLabel.text = mobileManager.statistics!.totalCredit!.stringValue
        semesterGradeLabel.text = "0.00"
        semesterCreditLabel.text = "0"
        
        semesterScores = mobileManager.semesterScores
        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(semesterScores.count), height: buttonHeight)
        for (index, semesterScore) in semesterScores.enumerated() {
            let button = UIButton(frame: CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: buttonHeight))
            let title = semesterScore.year! + (semesterScore.semester == "AW" ? "-1" : "-2")
            button.setTitle(title, for: .normal)
            button.tintColor = UIColor.white
            button.titleLabel!.font = UIFont.systemFont(ofSize: 14)
            button.tag = index
            button.addTarget(self, action: #selector(semesterWasSelected), for: .touchUpInside)
            scrollView.addSubview(button)
        }
        let offset = CGPoint(x: scrollView.contentSize.width - view.frame.width, y: 0)
        scrollView.setContentOffset(offset, animated: false)
        scrollView.scrollsToTop = false
        scrollView.addSubview(imageView)
        
        selectedIndex = semesterScores.count - 1
        refreshScores()
        
        NotificationCenter.default.addObserver(forName: .refreshCompleted, object: nil, queue: .main) { notification in
            self.semesterScores = self.mobileManager.semesterScores
            self.refreshScores()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func refreshScores() {
        if selectedIndex < 0 || selectedIndex >= semesterScores.count {
            return
        }
        let semesterScore = semesterScores[selectedIndex]
        semesterGradeLabel.text = String(format: "%.2f", semesterScore.averageGrade!.floatValue)
        semesterCreditLabel.text = semesterScore.totalCredit!.stringValue
        let semester = semesterScore.year! + (semesterScore.semester == "AW" ? "-1" : "-2")
        selectedScores = mobileManager.getScores(semester)
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
        
        imageView.frame = CGRect(x: buttonWidth * CGFloat(selectedIndex) + 38, y: 0, width: 23, height: 12)
    }
    
    @objc func semesterWasSelected(sender: UIButton) {
        selectedIndex = sender.tag
        refreshScores()
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
}

extension ScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Score") as! ScoreCell
        let score = selectedScores[indexPath.row]
        if score.managedObjectContext != nil {
            cell.nameLabel.text = score.name!
            cell.creditLabel.text = "\(score.credit!) 学分"
            cell.scoreLabel.text = String(format: "%.1f / %@", score.gradePoint!.floatValue, score.score!)
            cell.gauge.rate = CGFloat(truncating: score.gradePoint!)
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
}
