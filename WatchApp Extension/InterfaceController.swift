//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by kingcyk on 13/11/2017.
//  Copyright © 2017 QSC Tech. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var mainTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        request(eventsFor: Date())
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        request(eventsFor: Date())
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension InterfaceController {
    func request(eventsFor date: Date) {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isReachable {
                let message = ["date": date]
                session.sendMessage(message, replyHandler: { (reply: [String: Any]) -> Void in
                    if let titles = reply["titles"] as? String, let times = reply["times"] as? String, let places = reply["places"] as? String, let categories = reply["categories"] as? String {
                        print("[WC Session] Reply received by watchOS")
                        let titleArray = titles.components(separatedBy: "_")
                        let timeArray = times.components(separatedBy: "_")
                        let placeArray = places.components(separatedBy: "_")
                        let categoryArray = categories.components(separatedBy: "_")
                        DispatchQueue.main.async {
                            self.mainTable.setNumberOfRows(titleArray.count - 1, withRowType: "EventCell")
                            for i in 0..<titleArray.count - 1 {
                                let row = self.mainTable.rowController(at: i) as! EventTableRowController
                                row.name.setText(titleArray[i])
                                row.name.setTextColor(colors[Int(categoryArray[i])!])
                                row.time.setText(timeArray[i])
                                row.place.setText(placeArray[i])
                            }
                        }
                    }
                }, errorHandler: { (error: Error) in
                    print("[ERROR] Reply handler error: \(error.localizedDescription)")
                })
            } else {
                print("[WC Session] Not reachable")
            }
        }
    }
}
