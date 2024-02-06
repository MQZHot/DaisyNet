//
//  RequestManager.swift
//  DaisyNet
//
//  Created by MQZHot on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Alamofire
import Foundation

class RequestManager {
    static let `default` = RequestManager()

    func request(
        _ url: String,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        dynamicParams: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> RequestTaskManager
    {
        var tempParam = params == nil ? [:] : params!
        let dynamicTempParam = dynamicParams == nil ? [:] : dynamicParams!
        dynamicTempParam.forEach { arg in
            tempParam[arg.key] = arg.value
        }

        let key = cacheKey(url, params, dynamicParams)
        let taskManager = RequestTaskManager(url: url, method: method, params: tempParam, cacheKey: key, encoding: encoding, headers: headers)
        return taskManager
    }

    func request(
        urlRequest: URLRequestConvertible,
        params: Parameters,
        dynamicParams: Parameters? = nil)
        -> RequestTaskManager?
    {
        guard let urlStr = urlRequest.urlRequest?.url?.absoluteString else {
            return nil
        }
        let components = urlStr.components(separatedBy: "?")
        if components.count == 0 {
            return nil
        }
        let key = cacheKey(components.first!, params, dynamicParams)
        let taskManager = RequestTaskManager(urlRequest: urlRequest, cacheKey: key)
        return taskManager
    }

    /// 清除所有缓存
    func removeAllCache(completion: @escaping (Bool)->()) {
        CacheManager.default.removeAllCache(completion: completion)
    }

    /// 根据key值清除缓存
    func removeObjectCache(_ url: String, params: [String: Any]? = nil, dynamicParams: Parameters? = nil, completion: @escaping (Bool)->()) {
        let key = cacheKey(url, params, dynamicParams)
        CacheManager.default.removeObjectCache(key, completion: completion)
    }
}
