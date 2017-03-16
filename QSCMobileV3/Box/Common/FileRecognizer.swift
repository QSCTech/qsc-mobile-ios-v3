//
//  FileRecognizer.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/21.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import UIKit

class FileRecognizer {
    
    static func getFileIcon(fileName: String) -> UIImage {
        return UIImage(named: getFileIconName(fileName: fileName))!
    }
    
    static func getFileIconName(fileName: String) -> String {
        let lowercasedFileName = fileName.lowercased()
        var fileIconName: String!
        switch lowercasedFileName {
        case let name where name.hasSuffix(".pcb"), let name where name.hasSuffix(".dwg"), let name where name.hasSuffix(".ddb"):
            fileIconName = "CAD"
        case let name where name.hasSuffix(".zip"), let name where name.hasSuffix(".rar"), let name where name.hasSuffix(".7z"):
            fileIconName = "Compress"
        case let name where name.hasSuffix(".xls"), let name where name.hasSuffix(".xlsx"):
            fileIconName = "Excel"
        case let name where name.hasSuffix(".key"):
            fileIconName = "Key"
        case let name where name.hasSuffix(".mp3"), let name where name.hasSuffix(".wma"), let name where name.hasSuffix(".wav"), let name where name.hasSuffix(".mid"):
            fileIconName = "Music"
        case let name where name.hasSuffix(".numbers"):
            fileIconName = "Numbers"
        case let name where name.hasSuffix(".pages"):
            fileIconName = "Pages"
        case let name where name.hasSuffix(".pdf"):
            fileIconName = "PDF"
        case let name where name.hasSuffix(".jpg"), let name where name.hasSuffix(".png"), let name where name.hasSuffix(".bmp"), let name where name.hasSuffix(".gif"), let name where name.hasSuffix(".ico"), let name where name.hasSuffix("."):
            fileIconName = "Picture"
        case let name where name.hasSuffix(".ppt"), let name where name.hasSuffix(".pptx"):
            fileIconName = "PPT"
        case let name where name.hasSuffix(".exe"), let name where name.hasSuffix(".app"):
            fileIconName = "Program"
        case let name where name.hasSuffix(".txt"):
            fileIconName = "TXT"
        case let name where name.hasSuffix(".avi"), let name where name.hasSuffix(".mp4"), let name where name.hasSuffix(".mov"), let name where name.hasSuffix(".rmvb"), let name where name.hasSuffix(".rm"), let name where name.hasSuffix(".3gp"), let name where name.hasSuffix(".flv"):
            fileIconName = "Video"
        case let name where name.hasSuffix(".doc"), let name where name.hasSuffix(".docx"):
            fileIconName = "Word"
        default:
            fileIconName = "Unknown"
        }
        return fileIconName
    }
    
}
