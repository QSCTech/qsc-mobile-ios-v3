//
//  APISessionTests.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-28.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import XCTest
@testable import QSCMobileKit

class APISessionTests: XCTestCase {
    
    var session: APISession!
    
    override func setUp() {
        super.setUp()
        session = APISession(username: "freshman", password: "ios") { status, error in
            print(status, error)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHashHelpers() {
        XCTAssertEqual(session.generateSalt().length, 6)
        // and so on...
    }
    
}
