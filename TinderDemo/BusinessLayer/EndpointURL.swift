//
//  EndpointURL.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation

struct EndpointURL {
    static let baseURL = "https://randomuser.me"
    
    static let API_RANDOM_USER = "/api/"
    
    enum RequestParam {
        static let results = "results"
    }
}

extension String {
    var URLString: String {
        return EndpointURL.baseURL + self
    }
}
