//
//  UserServiceTests.swift
//  TinderDemoTests
//
//  Created by Thanh Pham on 9/25/20.
//

import XCTest

class UserServiceTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testThatGetUserReturnSuccess() {
        let didFinish = self.expectation(description: #function)
        
        var returnedResult: ([UserModel], Error?)?
        UserService.shared.getUsers(count: 5) { (userModels, error) in
            returnedResult = (userModels, error)
            didFinish.fulfill()
        }
        
        wait(for: [didFinish], timeout: 5)
        XCTAssertEqual(returnedResult?.0.count, 5)
    }
}
