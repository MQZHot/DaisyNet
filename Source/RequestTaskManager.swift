//
//  RequestTaskManager.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import UIKit
import Alamofire

// MARK: - 请求任务

public class RequestTaskManager: NSObject {
    var dataRequest: DataRequest
    var cache: Bool = false
    var cacheKey: String

    /// URL
    init(url: String,
         method: HTTPMethod = .get,
         params: Parameters? = nil,
         cacheKey: String,
         encoding: ParameterEncoding = URLEncoding.default,
         headers: HTTPHeaders? = nil)
    {
        self.cacheKey = cacheKey
        dataRequest = AF.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
        super.init()
    }

    /// Request
    init(urlRequest: URLRequestConvertible, cacheKey: String) {
        self.cacheKey = cacheKey
        dataRequest = AF.request(urlRequest)
        super.init()
    }

    /// 缓存data是否存在
    public func cacheDataIsExist()->Bool {
        let data = CacheManager.default.objectSync(forKey: cacheKey)?.data
        return data != nil
    }

    /// 是否缓存数据
    public func cache(_ cache: Bool)->RequestTaskManager {
        self.cache = cache
        return self
    }

    /// 获取缓存Data
    @discardableResult
    public func cacheData()->Data? {
        let dataResponse = DaisyDataResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        return dataResponse.cacheData()
    }

    /// 响应Data
    public func responseData(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<Data>)->()) {
        let dataResponse = DaisyDataResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        dataResponse.responseData(queue: queue, completion: completion)
    }

    /// 先获取Data缓存，再响应Data
    public func responseCacheAndData(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<Data>)->()) {
        let dataResponse = DaisyDataResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        dataResponse.responseCacheAndData(queue: queue, completion: completion)
    }

    /// 获取缓存String
    @discardableResult
    public func cacheString()->String? {
        let stringResponse = DaisyStringResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        return stringResponse.cacheString()
    }

    /// 响应String
    public func responseString(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<String>)->()) {
        let stringResponse = DaisyStringResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        stringResponse.responseString(queue: queue, completion: completion)
    }

    /// 先获取缓存String,再响应String
    public func responseCacheAndString(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<String>)->()) {
        let stringResponse = DaisyStringResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        stringResponse.responseCacheAndString(queue: queue, completion: completion)
    }

    /// 获取缓存JSON
    @discardableResult
    public func cacheJson()->Any? {
        let jsonResponse = DaisyJsonResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        return jsonResponse.cacheJson()
    }

    /// 响应JSON
    public func responseJson(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<Any>)->()) {
        let jsonResponse = DaisyJsonResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        jsonResponse.responseJson(queue: queue, completion: completion)
    }

    /// 先获取缓存JSON，再响应JSON
    public func responseCacheAndJson(queue: DispatchQueue = .main, completion: @escaping (DaisyResult<Any>)->()) {
        let jsonResponse = DaisyJsonResponse(dataRequest: dataRequest, cache: cache, cacheKey: cacheKey)
        jsonResponse.responseCacheAndJson(queue: queue, completion: completion)
    }
}
