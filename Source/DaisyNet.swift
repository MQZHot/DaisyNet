//
//  DaisyNet.swift
//  ZoneHot
//
//  Created by MQZHot on 2017/10/10.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//

import Alamofire
import UIKit

public class DaisyNet: NSObject {
    /// 缓存过期时间
    ///
    /// - Parameter expiry: 参考 DaisyExpiry
    public static func cacheExpiryConfig(expiry: DaisyExpiry) {
        CacheManager.default.expiryConfiguration(expiry: expiry)
    }

    /// 开启/关闭请求url log
    public static var log_url: Bool = true
    /// 开启/关闭结果log
    public static var log_result: Bool = false

    /// url请求
    @discardableResult
    public static func request(_ url: String,
                               method: HTTPMethod = .get,
                               params: Parameters? = nil,
                               encoding: ParameterEncoding = URLEncoding.default,
                               headers: HTTPHeaders? = nil) -> RequestTaskManager
    {
        return RequestTaskManager(url: url, method: method, params: params, encoding: encoding, headers: headers)
    }

    /// urlRequest请求
    @discardableResult
    public static func request(urlRequest: URLRequestConvertible) -> RequestTaskManager? {
        return RequestTaskManager(urlRequest: urlRequest)
    }
}

public extension DaisyNet {
    /// 缓存Data
    static func cacheData(with identifier: String) -> Data? {
        if let cacheKey = CacheKey.with(identifier),
           let data = CacheManager.default.objectSync(forKey: cacheKey)?.data
        {
            return data
        }
        return nil
    }

    /// 缓存String
    static func cacheString(with identifier: String) -> String? {
        if let cacheKey = CacheKey.with(identifier),
           let data = CacheManager.default.objectSync(forKey: cacheKey)?.data,
           let str = String(data: data, encoding: .utf8)
        {
            return str
        }
        return nil
    }

    /// 获取缓存json
    static func cacheJson(with identifier: String) -> Any? {
        if let cacheKey = CacheKey.with(identifier),
           let data = CacheManager.default.objectSync(forKey: cacheKey)?.data,
           let json = try? JSONSerialization.jsonObject(with: data, options: [])
        {
            return json
        }
        return nil
    }

    /// 缓存data是否存在
    static func cacheDataIsExist(with identifier: String?) -> Bool {
        if let key = CacheKey.with(identifier) {
            let data = CacheManager.default.objectSync(forKey: key)?.data
            return data != nil
        }
        return false
    }

    /// 清除所有缓存
    static func removeAllCache(completion: ((_ isSuccess: Bool) -> ())? = nil) {
        CacheManager.default.removeAllCache(completion: completion)
    }

    /// 根据identifier清除缓存
    static func removeCache(with identifier: String?, completion: ((_ isSuccess: Bool) -> ())? = nil) {
        if let key = CacheKey.with(identifier) {
            CacheManager.default.removeObjectCache(key, completion: completion)
        } else {
            completion?(false)
        }
    }
}
