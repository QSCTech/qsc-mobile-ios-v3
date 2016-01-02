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
    
    private override init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 10
        alamofireManager = Alamofire.Manager(configuration: configuration)
    }
    
    static let sharedInstance = NoticeAPI()
    
    private let alamofireManager: Alamofire.Manager
    
    private func noticeRequest(url: NSURL, callback: (JSON?, String?) -> Void) {
        let headers = ["X-Requested-With": "XMLHttpRequest"]
        
        alamofireManager.request(.GET, url, headers: headers)
            .responseJSON { response in
                if response.result.isFailure {
                    print("Notice request: \(response.result.error!.localizedDescription)")
                    callback(nil, "网络连接失败")
                    return
                }
                let json = JSON(response.result.value!)
                if json["code"].int == 0 {
                    callback(json["data"], nil)
                } else {
                    print("Notice request: \(json["message"].stringValue)")
                    callback(nil, "获取数据失败")
                }
        }
    }
    
    func getAllEventsWithPage(page: Int, callback: (JSON?, String?) -> Void) {
        let url = NSURL(string: "\(NoticeURL)/events?page=\(page)")!
        noticeRequest(url, callback: callback)
    }
    
    func getEventDetailWithId(id: String, callback: (JSON?, String?) -> Void) {
        let url = NSURL(string: "\(NoticeURL)/events/\(id)")!
        noticeRequest(url, callback: callback)
    }
    
    func downloadImage(url: NSURL, callback: (UIImage?) -> Void) {
        Alamofire.request(.GET, url)
                 .responseData { response in
                    if let data = response.result.value {
                        callback(UIImage(data: data))
                    } else {
                        callback(nil)
                    }
                 }
    }
    
}
