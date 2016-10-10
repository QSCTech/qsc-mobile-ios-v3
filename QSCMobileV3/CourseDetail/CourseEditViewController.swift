//
//  CourseEditViewController.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2016-07-08.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import QSCMobileKit

class CourseEditViewController: UITableViewController {
    
    var courseEvent: CourseEvent!
    
    @IBOutlet weak var teacherField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var taField: UITextField!
    @IBOutlet weak var taEmailField: UITextField!
    @IBOutlet weak var taPhoneField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var qqGroupField: UITextField!
    @IBOutlet weak var publicEmailField: UITextField!
    @IBOutlet weak var publicPasswordField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teacherField.text = courseEvent.teacher
        emailField.text = courseEvent.email
        phoneField.text = courseEvent.phone
        taField.text = courseEvent.ta
        taEmailField.text = courseEvent.taEmail
        taPhoneField.text = courseEvent.taPhone
        websiteField.text = courseEvent.website
        qqGroupField.text = courseEvent.qqGroup
        publicEmailField.text = courseEvent.publicEmail
        publicPasswordField.text = courseEvent.publicPassword
        notesTextView.text = courseEvent.notes
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        courseEvent.teacher = teacherField.text
        courseEvent.email = emailField.text
        courseEvent.phone = phoneField.text
        courseEvent.ta = taField.text
        courseEvent.taEmail = taEmailField.text
        courseEvent.taPhone = taPhoneField.text
        courseEvent.website = websiteField.text
        courseEvent.qqGroup = qqGroupField.text
        courseEvent.publicEmail = publicEmailField.text
        courseEvent.publicPassword = publicPasswordField.text
        courseEvent.notes = notesTextView.text
        EventManager.sharedInstance.save()
        dismiss(animated: true, completion: nil)
    }
    
}
