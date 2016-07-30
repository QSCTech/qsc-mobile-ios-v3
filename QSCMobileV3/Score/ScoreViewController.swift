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
    
    let mobileManager = MobileManager.sharedInstance
    
    var selectedScores = [Score]()
    
    @IBOutlet weak var semesterGradeLabel: UILabel!
    @IBOutlet weak var semesterCreditLabel: UILabel!
    @IBOutlet weak var averageGradeLabel: UILabel!
    @IBOutlet weak var totalCreditLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        averageGradeLabel.text = String(format: "%.2f", mobileManager.statistics.averageGrade!.floatValue)
        totalCreditLabel.text = mobileManager.statistics.totalCredit!.stringValue
        
        let semesters = mobileManager.allSemesters
        changeSemester(semesters.last ?? "")
        
        let buttonWidth = CGFloat(100)
        scrollView.contentSize = CGSize(width: buttonWidth * CGFloat(semesters.count), height: scrollView.frame.height)
        for (index, semester) in semesters.enumerate() {
            let button = UIButton(frame: CGRect(x: buttonWidth * CGFloat(index), y: 0, width: buttonWidth, height: scrollView.frame.height))
            button.tintColor = UIColor.whiteColor()
            button.setTitle(semester, forState: .Normal)
            button.titleLabel!.font = UIFont.systemFontOfSize(14)
            button.addTarget(self, action: #selector(semesterWasSelected), forControlEvents: .TouchUpInside)
            scrollView.addSubview(button)
        }
        let offset = CGPoint(x: scrollView.contentSize.width, y: 0)
        scrollView.setContentOffset(offset, animated: false)
        scrollView.scrollsToTop = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func changeSemester(semester: String) {
        semesterGradeLabel.text = "0.00"
        semesterCreditLabel.text = "0"
        let semesterScores = mobileManager.semesterScores
        for semesterScore in semesterScores {
            if semester.hasPrefix(semesterScore.year!) && ((semester.hasSuffix("1") && semesterScore.semester == "AW") || (semester.hasSuffix("2") && semesterScore.semester == "SS"))  {
                semesterGradeLabel.text = String(format: "%.2f", semesterScore.averageGrade!.floatValue)
                semesterCreditLabel.text = semesterScore.totalCredit!.stringValue
                break
            }
        }
        selectedScores = mobileManager.getScores(semester)
        tableView.reloadData()
    }
    
    func semesterWasSelected(sender: UIButton) {
        changeSemester(sender.currentTitle!)
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
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        let score = selectedScores[indexPath.row]
        cell.textLabel!.text = score.name
        cell.detailTextLabel!.text = score.gradePoint!.stringValue
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
}
