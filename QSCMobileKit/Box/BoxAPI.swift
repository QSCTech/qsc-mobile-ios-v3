//
//  BoxAPI.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/20.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class BoxAPI: NSObject {
    
    public static let sharedInstance = BoxAPI()
    
    public func getFileInfo(code: String, callback: @escaping (String, String, Any?) -> Void) {
        Alamofire.request("\(BoxURL)/item/issec/\(code)",method: .get).responseString {
            response in
            if let statuscode = response.response?.statusCode, statuscode == 200 {
                switch response.result.value! {
                case "WRONG":
                    callback(code, "Fail", "提取码不存在")
                case let result where result.hasPrefix("NO"):
                    callback(code, "Password", false)
                    callback(code, "Multi", result == "NO M")
                    callback(code, "Success", nil)
                case let result where result.hasPrefix("YES"):
                    callback(code, "Password", true)
                    callback(code, "Multi", result == "YESM")
                    callback(code, "Success", nil)
                default:
                    callback(code, "Fail", "云端文件信息格式错误")
                }
            } else {
                callback(code, "Fail", "云端文件信息获取失败")
            }
        }
    }
    
    public func checkPassword(code: String, password: String, isMulti: Bool, callback: @escaping (String, String, Any?) -> Void) {
        if isMulti == false {
            checkSingglePassword(code: code, password: password, callback: callback)
        } else {
            checkMultiPassword(code: code, password: password, callback: callback)
        }
    }
    
    private func checkSingglePassword(code: String, password: String, callback: @escaping (String, String, Any?) -> Void) {
        Alamofire.request("\(BoxURL)/item/get/\(code)/\(password)", method: .head)
            .response { response in
                if let response = response.response {
                    if response.allHeaderFields["Content-Disposition"] != nil {
                        callback(code, "Success", nil)
                    } else {
                        callback(code, "Fail", "私密分享码错误")
                    }
                } else {
                    callback(code, "Fail", "云端私密分享码获取失败")
                }
        }
    }
    
    private func checkMultiPassword(code: String, password: String, callback: @escaping (String, String, Any?) -> Void) {
        Alamofire.request("\(BoxURL)/item/get/\(code)/\(password)/json", method: .post).responseJSON { response in
            if response.result.error != nil {
                callback(code, "Fail", "云端私密分享码获取失败")
                return
            }
            let responsejson = JSON(response.result.value!)
            if responsejson["message"].string != nil {
                callback(code, "Fail", "私密分享码错误")
            } else {
                callback(code, "Success", nil)
            }
        }
    }
    
    public func getSinggleFileSuggestName(code: String, password: String, callback: @escaping (String, String, Any?) -> Void) {
        Alamofire.request("\(BoxURL)/item/get/\(code)/\(password)", method: .head)
            .response { response in
                if let response = response.response {
                    if response.allHeaderFields["Content-Disposition"] != nil {
                        callback(code, "Success", response.suggestedFilename!)
                    } else {
                        callback(code, "Fail", "获取文件名错误")
                    }
                } else {
                    callback(code, "Fail", "云端获取文件名失败")
                }
        }
    }
    
    public func getMultiFiles(code: String, password: String, callback: @escaping (String, String, Any?) -> Void) {
        Alamofire.request("\(BoxURL)/item/get/\(code)/\(password)/json", method: .post).responseJSON { response in
            if response.result.error != nil {
                callback(code, "Fail", "多文件信息获取失败")
                return
            }
            let responsejson = JSON(response.result.value!)
            if let message = responsejson["message"].string {
                callback(code, "Fail", message)
                return
            }
            for (_, subJson): (String, JSON) in responsejson["files"] {
                let item = ["id": String(subJson["id"].int!), "name": subJson["name"].string!, "size": subJson["filesizetext"].string!]
                callback(code, "Item", item)
            }
            callback(code, "Success", nil)
        }
    }
    
    public func download(code: String, password: String, multiSelect: [Int], destURL: URL, callback: @escaping (URL, String, Any?) -> Void) {
        let parameters: Parameters = [
            "download": 1,
            "file-select": multiSelect
        ]
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destURL, [.createIntermediateDirectories, .removePreviousFile])
        }
        let request = Alamofire.download("\(BoxURL)/item/get/\(code)/\(password)/json", method: .post, parameters: parameters, to: destination)
        request.downloadProgress { progress in
            if BoxManager.sharedInstance.getFileByFileURL(destURL) != nil {
                callback(destURL, "Progress", progress.fractionCompleted)
            } else {
                request.cancel()
            }
        }
        request.responseJSON { response in
            let dueDate = Date.completeStringToDate(string: response.response?.allHeaderFields["Expires"] as! String)
            callback(destURL, "DueDate", dueDate)
        }
        request.responseData { response in
            if let error = response.result.error {
                callback(destURL, "Fail", error.localizedDescription)
            }
            else {
                callback(destURL, "Success", nil)
            }
        }
    }

    public func upload(fileURL: URL, callback: @escaping (URL, String, Any?) -> Void) {
            Alamofire.upload(
            multipartFormData: { multipartFormData in multipartFormData.append(fileURL, withName: "file") },
            to: "\(BoxURL)/item/add_item",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    request.uploadProgress { progress in
                        if BoxManager.sharedInstance.getFileByFileURL(fileURL) != nil {
                            callback(fileURL, "Progress", progress.fractionCompleted)
                        } else {
                            request.cancel()
                        }
                    }
                    request.responseJSON {
                        response in
                        if response.result.error != nil {
                            callback(fileURL, "Fail", "网络故障")
                        } else {
                            let responsejson = JSON(response.result.value!)
                            if responsejson["err"] != 0 {
                                callback(fileURL, "Fail", responsejson["err"].stringValue)
                            } else {
                                callback(fileURL, "Code", responsejson["data"]["token"].string!)
                                callback(fileURL, "Secid", responsejson["data"]["secure_id"].string!)
                                callback(fileURL, "Success", nil)
                            }
                        }
                    }
                case .failure(let error):
                    callback(fileURL, "Fail", error.localizedDescription)
                }
            }
        )
    }
    
    public func set(fileURL: URL, oldcode: String, newcode: String, password: String?, secid: String, expiration: TimeInterval, callback: @escaping (URL, String, Any?) -> Void) {
        var parameters: Parameters = [
            "secure_id": secid,
            "new_token": newcode,
            "old_token": oldcode,
            "expiration": expiration,
            "jiami": 0
        ]
        if password != nil {
            parameters["jiami"] = 1
            parameters["token_sec"] = password
        }
        let request = Alamofire.request("\(BoxURL)/item/change_item", method: .post, parameters: parameters)
        request.responseJSON { response in
            if response.result.error != nil {
                callback(fileURL, "Fail", "网络故障")
            } else {
                let responsejson = JSON(response.result.value!)
                if responsejson["status"] == 0 {
                    callback(fileURL, "Code", newcode)
                    if password != nil {
                        callback(fileURL, "Password", password!)
                    }
                    callback(fileURL, "Expiration", expiration)
                    callback(fileURL, "Success", nil)
                } else {
                    callback(fileURL, "Fail", responsejson["message"].string!)
                }
            }
        }
    }
    
}
