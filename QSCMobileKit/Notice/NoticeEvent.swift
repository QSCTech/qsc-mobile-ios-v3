//
//  NoticeEvent.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-11.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit

public struct NoticeEvent {
    
    let id: String
    let name: String
    let place: String
    let summary: String
    let start: NSDate
    let end: NSDate
    let categoryId: String
    let categoryName: String
    let sponsorId: String
    let sponsorName: String
    let sponsorLogoURL: NSURL
    var sponsorLogo: UIImage?
    var bonus: String!
    var description: String!
    var poster: UIImage?
    
}
