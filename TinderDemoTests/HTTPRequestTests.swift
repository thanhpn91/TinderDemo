//
//  HTTPRequestTests.swift
//  TinderDemoTests
//
//  Created by Thanh Pham on 9/24/20.
//

import XCTest

struct HTTPRequestMock: HTTPRequestable {
    
    static var getRequest: URLRequest?
    
    static func makeURLRequest(urlComponent: URLComponents?, cachePolicy: NSURLRequest.CachePolicy, timeoutInterval: TimeInterval) -> URLRequest? {
        return nil
    }
    
    static func GET_request(urlRequest: URLRequest, completion: @escaping ((Result<Data>) -> Void)) {
        getRequest = urlRequest
    }
}

class HTTPRequestTests: XCTestCase {
    
    var mockURLComponent: URLComponents?
    
    override func setUp() {
        var mockURLComponent = URLComponents(string: EndpointURL.API_RANDOM_USER.URLString)
        mockURLComponent?.queryItems = [
             URLQueryItem(name: "mockproperty", value: "mockvalue")
        ]
    }

    override func tearDown() {
        mockURLComponent = nil
    }

    func testThatMakeURLRequestBuildCorrectRequest() {
        guard let request = HTTPRequest.makeURLRequest(urlComponent: mockURLComponent) else {
            XCTAssertFalse(false, "fail to make url request")
            return
        }
        
        XCTAssertEqual(request.url?.absoluteString, mockURLComponent?.url?.absoluteString)
    }
    
    func testThatGET_requestCallWithCorrectInput() {
        guard let request = HTTPRequest.makeURLRequest(urlComponent: mockURLComponent) else {
            XCTAssertFalse(false, "fail to make url request")
            return
        }
        
        HTTPRequestMock.GET_request(urlRequest: request) { (data) in
            XCTAssertEqual(request, HTTPRequestMock.getRequest)
        }
    }
}
