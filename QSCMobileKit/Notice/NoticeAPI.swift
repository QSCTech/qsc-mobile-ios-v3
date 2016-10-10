//
//  NoticeAPI.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-10.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NoticeAPI: NSObject {
    
    static let sharedInstance = NoticeAPI()
    
    private let alamofire = alamofireManager(timeoutInterval: 10)
    
    private func noticeRequest(_ url: URL, callback: @escaping (JSON?, String?) -> Void) {
        let headers = ["X-Requested-With": "XMLHttpRequest"]
        
        alamofire.request(url, headers: headers).responseJSON { response in
            if response.result.isFailure {
                print("[Notice request] \(response.result.error!.localizedDescription)")
                callback(nil, "网络连接失败")
                return
            }
            let json = JSON(response.result.value!)
            if json["code"].int == 0 {
                callback(json["data"], nil)
            } else {
                print("[Notice request] \(json["message"].stringValue)")
                callback(nil, "获取数据失败")
            }
        }
    }
    
    func getAllEventsWithPage(_ page: Int, callback: @escaping (JSON?, String?) -> Void) {
        let url = URL(string: "\(NoticeURL)/events?page=\(page)")!
        noticeRequest(url, callback: callback)
    }
    
    func getEventDetailWithId(_ id: String, callback: @escaping (JSON?, String?) -> Void) {
        let url = URL(string: "\(NoticeURL)/events/\(id)")!
        noticeRequest(url, callback: callback)
    }
    
}
