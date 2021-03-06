//
//  HTTPRequest.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation

enum Result<T> {
    case success(T?)
    case failure(Error)
}

enum APIError: Error {
    case noResponse
    case unsuccesfulStatusCode(Int)
    case timeout(String)
    case responseError(String)
    case noNetwork(String)
}

protocol HTTPRequestable {
    static func makeURLRequest(urlComponent: URLComponents?,
                                cachePolicy: NSURLRequest.CachePolicy,
                            timeoutInterval: TimeInterval) -> URLRequest?
    
    static func GET_request(urlRequest: URLRequest,
                            completion: @escaping ((Result<Data>) -> Void))
}

struct HTTPRequest: HTTPRequestable {
    
    private static var successCodes: Range<Int> = 200..<299
    
    static func setupCache() {
        let memoryCacheSize = 100*1024*1024
        let diskCacheSize = 200*1024*1024
        URLCache.configSharedCache(directory: nil, memory: memoryCacheSize, disk: diskCacheSize)
    }
    
    static func makeURLRequest(urlComponent: URLComponents?,
                               cachePolicy: NSURLRequest.CachePolicy = .returnCacheDataElseLoad,
                               timeoutInterval: TimeInterval = 5) -> URLRequest? {
        guard let url = urlComponent?.url else {return nil}
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval
        return request
    }
    
    static func GET_request(urlRequest: URLRequest, completion: @escaping ((Result<Data>) -> Void)) {
        let session = URLSession.shared
        var task: URLSessionDataTask?
        
        task = session.dataTask(with: urlRequest) { (data: Data?, response:URLResponse?, error:Error?) in
            
            guard let error = error else {
                self.evaluate(data: data, response: response, completion: completion)
                return
            }
            
            completion(.failure(error))
        }
        
        task?.resume()
    }
    
    fileprivate static func evaluate(data: Data?, response: URLResponse?, completion: ((Result<Data>) -> Void)) {
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(APIError.noResponse))
            return
        }
        
        debugPrint(httpResponse)
        handleResponse(data: data, httpResponse: httpResponse, completion: completion)
    }
    
    fileprivate static func handleResponse(data: Data?, httpResponse: HTTPURLResponse, completion: ((Result<Data>) -> Void)) {
        guard successCodes.contains(httpResponse.statusCode) else {
            completion(.failure(APIError.unsuccesfulStatusCode(httpResponse.statusCode)))
            return
        }
        
        guard let data = data else {
            completion(.success(nil))
            return
        }
        
        completion(.success(data))
    }
}

extension URLCache {
    static func configSharedCache(directory: String? = Bundle.main.bundleIdentifier, memory: Int = 0, disk: Int = 0) {
        URLCache.shared = {
            let cacheDirectory = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String).appendingFormat("/\(directory ?? "cache")/" )
            return URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: cacheDirectory)
        }()
    }
}
