//
//  TinderInteractor.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation

class TinderInteractor: TinderInteractorInterface {
    weak var view: TinderViewControllerInterface?
        
    private let resultCount = 50
    var userModels = SynchronizedArray<UserModel>()
    var favoriteList = SynchronizedArray<UserModel>()
    var displayedFavoriteList = false
    
    var userService: UserServiceable?
    init(service: UserServiceable? = UserService.shared,
         userModels: [UserModel] = [],
         favorite: [UserModel] = []) {
        
        self.userService = service
        self.userModels += userModels
        self.favoriteList += favorite
    }
        
    func onViewReadyToLoad() {
        favoriteList += UserDefaults.standard.loadFavoriteList()
        fetchSuggestedUsersAndReload()
    }
    
    private func fetchSuggestedUsersAndReload() {
        self.view?.display(.loading)
        userService?.getUsers(count: resultCount, completion: { [weak self](userModels, error) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.view?.display(.ready)
                if let error = error {
                    self.view?.display(error.localizedDescription)
                    return
                }
                
                if userModels.count > 0 {
                    self.userModels += userModels
                }
                
                let displayItems = self.parse(self.userModels.all)
                self.view?.display(displayItems)
            }
        })
    }
    
    func onViewSelectFavoriteList() {
        let displayItems = self.parse(favoriteList.all)
        self.view?.display(displayItems)
    }
    
    func onViewDeselectFavoriteList() {
        let displayItems = self.parse(userModels.all)
        self.view?.display(displayItems)
    }
    
    func onViewAddToFavoriteItemAtIndex(_ index: Int) {
        guard !displayedFavoriteList else {return}
        
        if index < userModels.count, let userModel = userModels[index] {
            favoriteList.append(userModel)
            UserDefaults.standard.storeFavoriteList(favoriteList.all)
        }
    }
    
    func onViewRemoveItemAtIndex(_ index: Int) {
        if displayedFavoriteList {
            if index < favoriteList.count {
                favoriteList.remove(at: index)
            }
        } else {
            if index < userModels.count {
                userModels.remove(at: index)
            }
        }
    }
    
    private func parse(_ userModels: [UserModel]) -> [TinderCardDisplayItem] {
        return userModels.compactMap { (userModel) -> TinderCardDisplayItem in
            return TinderCardDisplayItem(name: userModel.name.fullName,
                                         picture: userModel.picture.large,
                                         email: userModel.email,
                                         dob: userModel.dob.date?.getFormattedDate(format: "dd/MM/yyyy") ?? "",
                                         address: userModel.address.fullAddress,
                                         phone: userModel.phone,
                                         password: userModel.login.password)
        }
    }
}

extension UserDefaults {
    func storeFavoriteList(_ userModels: [UserModel]) {
        let data = userModels.compactMap{ try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: "favoritelist")
    }
    
    func loadFavoriteList() -> [UserModel] {
        guard let data = UserDefaults.standard.object(forKey: "favoritelist") as? [Data] else {
            return []
        }
        
        return data.compactMap{ try? JSONDecoder().decode(UserModel.self, from: $0) }
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

