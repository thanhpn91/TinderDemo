//
//  TinderInteractorTests.swift
//  TinderDemoTests
//
//  Created by Thanh Pham on 9/25/20.
//

import XCTest

class UserServiceMock: UserServiceable {
    var isGetUserCalled = false
        
    var userModels: [UserModel] = []
    var error: Error?
    
    func getUsers(count: Int, completion: (([UserModel], Error?) -> Void)?) {
        isGetUserCalled = true
        completion?(userModels, error)
    }
}

class TinderViewControllerMock: TinderViewControllerInterface {
    
    var interactor: TinderInteractorInterface?
    
    var viewStateDisplayed: ViewState = .ready
    var errorMsgDisplayed = false
    var successDisplayItem = false
    
    var displayItems = [TinderCardDisplayItem]()
    
    func display(_ viewState: ViewState) {
        viewStateDisplayed = viewState
    }
       
    func display(_ errorMsg: String) {
        errorMsgDisplayed = true
    }
       
    func display(_ displayItems: [TinderCardDisplayItem]) {
        self.displayItems = displayItems
        successDisplayItem = true
    }
}

class TinderInteractorTests: XCTestCase {
    
    var viewController: TinderViewControllerMock?
    var interactor: TinderInteractor?
    var userService: UserServiceMock?

    override func setUp() {
        viewController = TinderViewControllerMock()
        userService = UserServiceMock()
        interactor = TinderInteractor(service: userService)
        interactor?.view = viewController
        viewController?.interactor = interactor
    }

    override func tearDown() {
    }
    
    func testThatInteractorRequestForUsersWhenViewIsLoaded() {
        interactor?.view = viewController
        viewController?.interactor = interactor
        
        interactor?.onViewReadyToLoad()
        XCTAssertEqual(userService?.isGetUserCalled, true)
    }
    
    func testThatShowDisplayDataFromSuccessResponse() {
        interactor?.view = viewController
        viewController?.interactor = interactor
        
        let didFinish = self.expectation(description: #function)
        
        userService?.userModels = []
        interactor?.onViewReadyToLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            didFinish.fulfill()
        }
        
        wait(for: [didFinish], timeout: 5)
        
        XCTAssertEqual(self.userService?.isGetUserCalled, true)
        XCTAssertEqual(self.viewController?.successDisplayItem, true)
    }
    
    func testThatShowErrorDataFromErrorResponse() {
        interactor?.view = viewController
        viewController?.interactor = interactor
        
        let didFinish = self.expectation(description: #function)
        
        userService?.error = NSError(domain: "error", code: 404, userInfo: [:])
        interactor?.onViewReadyToLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            didFinish.fulfill()
        }
        
        wait(for: [didFinish], timeout: 5)
        
        XCTAssertEqual(self.userService?.isGetUserCalled, true)
        XCTAssertEqual(self.viewController?.errorMsgDisplayed, true)
    }
    
    func testThatRemoveUserWhenSwipeLeft() {
        interactor?.userModels += [UserModel.userStub()]
        XCTAssertEqual(interactor?.userModels.count, 1)
        
        interactor?.onViewRemoveItemAtIndex(0)
        XCTAssertEqual(interactor?.userModels.count, 0)
        XCTAssertEqual(viewController?.displayItems.count, 0)
    }
    
    func testThatAddToFavoriteWhenSwipeRight() {
        interactor?.userModels += [UserModel.userStub()]
        XCTAssertEqual(interactor?.userModels.count, 1)
        
        XCTAssertEqual(interactor?.favoriteList.count, 0)
        interactor?.onViewAddToFavoriteItemAtIndex(0)
        XCTAssertEqual(interactor?.favoriteList.count, 1)
    }
    
    func testThatRemoveFromFavoriteWhenSwipingLeft() {
        interactor?.favoriteList += [UserModel.userStub()]
        interactor?.displayedFavoriteList = true
        XCTAssertEqual(interactor?.favoriteList.count, 1)
        
        interactor?.onViewRemoveItemAtIndex(0)
        XCTAssertEqual(interactor?.userModels.count, 0)
        XCTAssertEqual(interactor?.favoriteList.count, 0)
    }
    
    func testThatLoadFavoriteListWhenTappingFavoriteButton() {
        interactor?.userModels += [UserModel.userStub(), UserModel.userStub()]
        interactor?.favoriteList += [UserModel.userStub()]
        interactor?.onViewSelectFavoriteList()
        XCTAssertEqual(viewController?.displayItems.count, 1)
    }
    
    func testThatLoadNormalListWhenDeselectFavoriteButton() {
        interactor?.userModels += [UserModel.userStub(), UserModel.userStub()]
        interactor?.favoriteList += [UserModel.userStub()]
        interactor?.onViewDeselectFavoriteList()
        XCTAssertEqual(viewController?.displayItems.count, 2)
    }
}
