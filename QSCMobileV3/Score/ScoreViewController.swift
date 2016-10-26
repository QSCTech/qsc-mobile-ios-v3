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
        super.init(nibName: "ScoreViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private let buttonWidth = CGFloat(100)
    private let mobileManager = MobileManager.sharedInstance
    
    private var semesterScores = [SemesterScore]()
    private var selectedScores = [Score]()
    
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
        tableView.registerNib(UINib(nibName: "ScoreCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "Score")
        
        averageGradeLabel.text = String(format: "%.2f", mobileManager.statistics!.averageGrade!.floatValue)
        totalCreditLabel.text = mobileManager.statistics!.totalCredit!.stringValue
        semesterGradeLabel.text = "0.00"
        semesterCreditLabel.text = "0"
        
        semesterScores = mobileManager.semesterScores
        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(semesterScores.count), height: scrollView.frame.height)
        for (index, semesterScore) in semesterScores.enumerate() {
            let button = UIButton(frame: CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: scrollView.frame.height))
            let title = semesterScore.year! + (semesterScore.semester == "AW" ? "-1" : "-2")
            button.setTitle(title, forState: .Normal)
            button.tintColor = UIColor.whiteColor()
            button.titleLabel!.font = UIFont.systemFontOfSize(14)
            button.tag = index
            button.addTarget(self, action: #selector(semesterWasSelected), forControlEvents: .TouchUpInside)
            scrollView.addSubview(button)
        }
        let offset = CGPoint(x: scrollView.contentSize.width, y: 0)
        scrollView.setContentOffset(offset, animated: false)
        scrollView.scrollsToTop = false
        scrollView.addSubview(imageView)
        
        changeSemester(semesterScores.count - 1)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func changeSemester(index: Int) {
        if index < 0 {
            return
        }
        let semesterScore = semesterScores[index]
        semesterGradeLabel.text = String(format: "%.2f", semesterScore.averageGrade!.floatValue)
        semesterCreditLabel.text = semesterScore.totalCredit!.stringValue
        let semester = semesterScore.year! + (semesterScore.semester == "AW" ? "-1" : "-2")
        selectedScores = mobileManager.getScores(semester)
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
        
        imageView.frame = CGRect(x: buttonWidth * CGFloat(index) + 38, y: 0, width: 23, height: 12)
    }
    
    func semesterWasSelected(sender: UIButton) {
        changeSemester(sender.tag)
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension ScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedScores.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Score") as! ScoreCell
        let score = selectedScores[indexPath.row]
        cell.nameLabel.text = score.name!
        cell.creditLabel.text = "\(score.credit!) 学分"
        cell.scoreLabel.text = String(format: "%.1f / %@", score.gradePoint!.floatValue, score.score!)
        cell.gauge.rate = CGFloat(score.gradePoint!)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
}
