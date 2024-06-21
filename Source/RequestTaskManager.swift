//
//  RequestTaskManager.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import Alamofire
import UIKit

// MARK: - 请求任务

public class RequestTaskManager: NSObject {
    var dataRequest: DataRequest
    var cacheKey: String?

    /// URL
    init(url: String,
         method: HTTPMethod = .get,
         params: Parameters? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil)
    {
        dataRequest = AF.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
        super.init()
    }

    /// Request
    init(urlRequest: URLRequestConvertible) {
        dataRequest = AF.request(urlRequest)
        super.init()
    }

    /// 缓存Key
    public func cacheIdentifier(_ identifier: String?)->RequestTaskManager {
        self.cacheKey = CacheKey.with(identifier)
        return self
    }

    /// 重定向
    @discardableResult
    public func redirect(using handler: RedirectHandler)->RequestTaskManager {
        dataRequest.redirect(using: handler)
        return self
    }

    /// 响应Data
    public func responseData(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<Data>)->()) {
        let dataResponse = DaisyResponseData(dataRequest: dataRequest, cacheKey: cacheKey)
        dataResponse.responseData(queue: queue, completion: completion)
    }

    /// 响应String
    public func responseString(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<String>)->()) {
        let stringResponse = DaisyResponseString(dataRequest: dataRequest, cacheKey: cacheKey)
        stringResponse.responseString(queue: queue, completion: completion)
    }

    /// 响应JSON
    public func responseJson(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<Any>)->()) {
        let jsonResponse = DaisyResponseJson(dataRequest: dataRequest, cacheKey: cacheKey)
        jsonResponse.responseJson(queue: queue, completion: completion)
    }
}
