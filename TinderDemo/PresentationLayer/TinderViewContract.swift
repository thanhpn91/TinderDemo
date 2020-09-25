//
//  TinderViewContract.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation

struct TinderCardDisplayItem {
    var name: String
    var picture: String
    var email: String
    var dob: String
    var address: String
    var phone: String
    var password: String
}

public enum ViewState {
    case loading
    case ready
}

protocol TinderViewControllerInterface: class {
    func display(_ viewState: ViewState)
    func display(_ errorMsg: String)
    func display(_ displayItems: [TinderCardDisplayItem])
}

protocol TinderInteractorInterface {
    var view: TinderViewControllerInterface? {get set}
    
    func onViewReadyToLoad()
    func onViewSelectFavoriteList()
    func onViewDeselectFavoriteList()
    func onViewAddToFavoriteItemAtIndex(_ index: Int)
    func onViewRemoveItemAtIndex(_ index: Int)
}
