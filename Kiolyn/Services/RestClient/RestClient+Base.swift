//
//  RestClient+Generics.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 6/3/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

extension RestClient {
    
    /// A common GET for single object.
    ///
    /// - Parameter url: the GET path.
    /// - Returns: the single of the result.
    func load<T: Mappable>(model path: String) -> Single<T?> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just(nil)
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/\(path)"
            Alamofire.request(endpoint)
                .log()
                .responseObject(queue: self.queue) { (res: DataResponse<T>) in
                    //v("RES - \(String(data: res.data!, encoding: .utf8))")
                    if let error = res.error {
                        e(error)
                    }
                    single(.success(res.value))
            }
            return Disposables.create()
        }
    }
    
    /// Get path which return list of objects.
    ///
    /// - Parameter path: the GET path.
    /// - Returns: the Single of list of object.
    func load<T: Mappable>(multiModel path: String, params: [String: Any] = [:]) -> Single<[T]> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just([])
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/\(path)"
            Alamofire.request(endpoint, method: .get, parameters: params)
                .log()
                .responseArray(queue: self.queue) { (res: DataResponse<[T]>) in
                    //v("RES - \(String(data: res.data!, encoding: .utf8))")
                    if let error = res.error {
                        e(error)
                    }
                    single(.success(res.value ?? []))
            }
            return Disposables.create()
        }
    }
    
    /// A common POST with result.
    ///
    /// - Parameters:
    ///   - url: the POST path.
    ///   - data: the POST data.
    /// - Returns: Single of the result.
    func post<T>(path: String, data: [String: Any]) -> Single<T?> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just(nil)
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/\(path)"
            Alamofire.request(endpoint, method: .post, parameters: data, encoding: JSONEncoding.default)
                .log()
                .responseJSON(queue: self.queue) { (res: DataResponse<Any>) in
                    //v("RES - \(String(data: res.data!, encoding: .utf8))")
                    if let error = res.error {
                        e(error)
                    }
                    // Special case when expecting String (the only case so far is the revision of
                    // the saved object). We have different returned result from different Main.
                    var result: T? = nil
                    // If it can be cast directly, it should be fine
                    if let value = res.value as? T {
                        result = value
                    } else if let value = res.value as? [String: Any] {
                        result = value["result"] as? T
                    }
                    single(.success(result))
            }
            return Disposables.create()
        }
    }
    
    /// A common POST with result.
    ///
    /// - Parameters:
    ///   - url: the POST path.
    ///   - data: the POST data.
    /// - Returns: Single of the result.
    func post<T: Mappable>(model path: String, data: [String: Any]) -> Single<T?> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just(nil)
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/\(path)"
            Alamofire.request(endpoint, method: .post, parameters: data, encoding: JSONEncoding.default)
                .log()
                .responseObject(queue: self.queue) { (res: DataResponse<T>) in
                    //v("RES - \(String(data: res.data!, encoding: .utf8))")
                    if let error = res.error {
                        e(error)
                    }
                    single(.success(res.value))
            }
            return Disposables.create()
        }
    }
    
    /// Delete with given path
    ///
    /// - Parameter path: the DELETE path
    /// - Returns: Single of the result.
    func delete(model path: String) -> Single<()> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just(())
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/\(path)"
            Alamofire.request(endpoint, method: .delete)
                .log()
                .responseJSON { res in
                    //v("RES - \(String(data: res.data!, encoding: .utf8))")
                    if let error = res.error {
                        e(error)
                    }
                    return single(.success(()))
            }
            return Disposables.create()
        }
    }
    
    /// Get with QueryResult as returned type.
    ///
    /// - Parameter path: the QUERY path.
    /// - Returns: Single of the result.
    func query<T: BaseModel>(model path: String, params: [String: Any] = [:]) -> Single<QueryResult<T>> {
        guard let mainURL = self.mainURL?.absoluteString else {
            return Single.just(QueryResult())
        }
        return Single.create { single in
            let endpoint = "\(mainURL)/\(path)"
            Alamofire.request(endpoint, method: .get, parameters: params)
                .log()
                .responseObject(queue: self.queue) { (res: DataResponse<QueryResult<T>>) in
                    //v("RES - \(String(data: res.data!, encoding: .utf8))")
                    if let error = res.error {
                        e(error)
                    }
                    single(.success(res.value ?? QueryResult()))
            }
            return Disposables.create()
        }
    }
}

// MARK: - For logging request
extension Request {
    func log() -> Self {
        v(self)
        return self
    }
}

fileprivate let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    var asParameters: Parameters {
        return [arrayParametersKey: self]
    }
}

/// Convert the parameters into a json array, and it is added as the request body.
/// The array must be sent as parameters using its `asParameters` method.
struct ArrayEncoding: ParameterEncoding {
    
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    
    
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}
