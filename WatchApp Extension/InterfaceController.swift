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
    // MARK: - Watch Connectivity
    func request(eventsFor date: Date) {
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isReachable {
                let message = ["date": date]
                session.sendMessage(message, replyHandler: { (reply: [String: Any]) -> Void in
                    if let result = reply["result"] as? [String: [String: Any]] {
                        print("[WC Session] Reply received by watchOS")
                        DispatchQueue.main.async {
                            self.mainTable.setNumberOfRows(result.count, withRowType: "EventCell")
                            for (index, subResult): (String, [String: Any]) in result {
                                let row = self.mainTable.rowController(at: Int(index)!) as! EventTableRowController
                                row.name.setText(subResult["name"] as? String)
                                let rawColors = subResult["color"] as! [NSNumber]
                                let colors = rawColors.map { (CGFloat)($0.floatValue) }
                                row.name.setTextColor(UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: colors[3]))
                                row.time.setText(subResult["time"] as? String)
                                row.place.setText(subResult["place"] as? String)
                            }
                        }
                    }
                }, errorHandler: { (error: Error) in
                    print("[WC Session] Reply handler error: \(error.localizedDescription)")
                })
            } else {
                print("[WC Session] Not reachable")
            }
        }
    }
}
