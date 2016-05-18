//
//  NoticeEvent.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-12-11.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import UIKit

public struct NoticeEvent {
    
    public let id: String
    public let name: String
    public let place: String
    public let summary: String
    public let start: NSDate
    public let end: NSDate
    public let categoryId: String
    public let categoryName: String
    public let sponsorId: String
    public let sponsorName: String
    public let sponsorLogoURL: NSURL
    public var bonus: String!
    public var content: String!
    public var posterURL: NSURL!
    
}
