//
//  UserService.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation

protocol UserServiceable {
    func getUsers(count: Int, completion: (([UserModel], Error?) -> Void)?)
}

public class UserService: UserServiceable {
    static let shared = UserService()
    
    private var networkRequest: HTTPRequestable!
    init(networkRequest: HTTPRequestable = HTTPRequest()) {
        self.networkRequest = networkRequest
    }
    
    func getUsers(count: Int, completion: (([UserModel], Error?) -> Void)?) {
        var urlComponent = URLComponents(string: EndpointURL.API_RANDOM_USER.URLString)
        urlComponent?.queryItems = [
            URLQueryItem(name: EndpointURL.RequestParam.results, value: "\(count)")
        ]
        
        guard let request = HTTPRequest.makeURLRequest(urlComponent: urlComponent) else {return}
        HTTPRequest.GET_request(urlRequest: request) {(result) in
            switch result {
            case .success(let data):
                if let data = data {
                    do {
                        let userModelList = try JSONDecoder().decode(UserModelResponse.self, from: data)
                        completion?(userModelList.userModels, nil)
                    } catch  {
                        print(error)
                        completion?([], error)
                    }
                }
                break
            case .failure(let error):
                completion?([], error)
                break
            }
        }
    }
}
