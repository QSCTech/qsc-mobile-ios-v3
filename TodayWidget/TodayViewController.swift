//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by kingcyk on 2016/11/1.
//  Copyright © 2016年 QSC Tech. All rights reserved.
//

import UIKit
import NotificationCenter
import KeychainAccess
import QSCMobileKit

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tskList: UITableView!
    let events = eventsForDate(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOSApplicationExtension 10, *) { // Only in iOS 10
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        tskList.register(UINib(nibName: "TableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Event")
        tskList.rowHeight = 60.0
        self.preferredContentSize.height = CGFloat(self.events.count) * tskList.rowHeight
        tskList.reloadData()
        // Do any additional setup after loading the view from its nib.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = events[indexPath.row]
        // let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Event")
        // Temporary
        let cell = tskList.dequeueReusableCell(withIdentifier: "Event") as! TableViewCell
        cell.startTime.text = event.start.stringOfTime
        cell.endTime.text = event.end.stringOfTime
        cell.eventName.text = event.name
        cell.eventPlace.text = event.place
        
        // cell.textLabel?.text = event.name
        //cell.detailTextLabel?.text = event.place + ", " + event.time
        return cell
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == .compact) {
            self.preferredContentSize.height = 150
        } else {
            // max Event count = 9
            self.preferredContentSize.height = 150 + CGFloat(events.count) * tskList.rowHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        tskList.rowHeight = 44.0
        //self.preferredContentSize.height = CGFloat(self.events.count + 1) * 44.0
        tskList.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
    
}
