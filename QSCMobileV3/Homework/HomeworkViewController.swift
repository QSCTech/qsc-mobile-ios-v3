//
//  HomeworkViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-09-04.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

protocol HomeworkViewControllerDelegate: class {
    func refresh()
}

class HomeworkViewController: UITableViewController {
    
    var homework: Homework!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var detailView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var finishSwitch: UISwitch!
    weak var delegate: HomeworkViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = homework.name
        detailView.text = homework.notes
        datePicker.date = homework.deadline ?? Date()
        finishSwitch.isOn = homework.isFinished?.boolValue ?? false
        
        datePicker.timeZone = TimeZone(identifier: "Asia/Shanghai")
        
        nameDidChange(nameField)
        detailView.delegate = self
        textViewDidChange(detailView)
        
        view.backgroundColor = ColorCompatibility.systemBackground
        detailView.backgroundColor = UIColor(white: 0, alpha: 0)
        
        if #available(iOS 13, *) {
            self.isModalInPresentation = true
        }
    }
    
    @IBAction func nameDidChange(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = !sender.text!.isEmpty
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        if homework.addTime == nil {
            EventManager.sharedInstance.removeHomework(homework)
        }
        
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        homework.name = nameField.text
        homework.notes = detailView.text
        homework.addTime = homework.addTime ?? Date()
        homework.deadline = datePicker.date
        homework.isFinished = finishSwitch.isOn as NSNumber
        EventManager.sharedInstance.save()
        
        delegate?.refresh()
        dismiss(animated: true)
    }
    
}

extension HomeworkViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}
