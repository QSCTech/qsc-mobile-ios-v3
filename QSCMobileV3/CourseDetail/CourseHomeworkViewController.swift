//
//  CourseHomeworkViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-09-04.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class CourseHomeworkViewController: UITableViewController {
    
    var homework: Homework!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = homework.name
        detailView.text = homework.notes
        datePicker.date = homework.deadline ?? NSDate()
        
        detailView.delegate = self
        textViewDidChange(detailView)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if homework.addTime == nil {
            EventManager.sharedInstance.removeHomework(homework)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        homework.name = nameField.text
        homework.notes = detailView.text
        homework.addTime = homework.addTime ?? NSDate()
        homework.deadline = datePicker.date
        homework.isFinished = false
        EventManager.sharedInstance.save()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension CourseHomeworkViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    
}
