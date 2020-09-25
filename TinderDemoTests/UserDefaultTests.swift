//
//  UserDefaultTests.swift
//  TinderDemoTests
//
//  Created by Thanh Pham on 9/25/20.
//

import XCTest

class UserDefaultTests: XCTestCase {
    
    override func setUp() {
    }

    override func tearDown() {
    }
    
    func testThatSuccessStoreFavoriteList() {
        let userModel = UserModel.userStub()
        UserDefaults.standard.storeFavoriteList([userModel])
        
        let favoriteList = UserDefaults.standard.loadFavoriteList()
        XCTAssertEqual(favoriteList.count, 1)
        
        XCTAssertNotNil(favoriteList.first)
        if let savedModel = favoriteList.first {
            XCTAssertEqual(userModel.name.fullName, savedModel.name.fullName)
        }
    }
}
