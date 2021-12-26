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
import Cache
import UIKit

/// 缓存过期时间
///
/// - Parameter expiry: 参考 DaisyExpiry
public func cacheExpiryConfig(expiry: DaisyExpiry) {
    CacheManager.default.expiryConfiguration(expiry: expiry)
}

/// 超时时间
///
/// - Parameter timeInterval: 超时时间
public func timeoutIntervalForRequest(_ timeInterval: TimeInterval) {
    RequestManager.default.timeoutIntervalForRequest(timeInterval)
}

// MARK: - 网络请求

/// 开启/关闭请求url log
public var openUrlLog: Bool = true
/// 开启/关闭结果log
public var openResultLog: Bool = true

/// 网络请求
///
/// - Parameters:
///   - url: url
///   - method: .get .post ...
///   - params: 参数字典
///   - dynamicParams: 变化的参数，例如 时间戳-token 等
///   - encoding: 编码方式
///   - headers: 请求头
/// - Returns:
@discardableResult
public func request(
    _ url: String,
    method: HTTPMethod = .get,
    params: Parameters? = nil,
    dynamicParams: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    -> RequestTaskManager
{
    return RequestManager.default.request(url, method: method, params: params, dynamicParams: dynamicParams, encoding: encoding, headers: headers)
}

/// urlRequest请求
///
/// - Parameters:
///   - urlRequest: 自定义URLRequest
///   - params: URLRequest中需要的参数，作为key区分缓存
///   - dynamicParams: 变化的参数，例如 时间戳, `token` 等, 用来过滤`params`中的动态参数
/// - Returns: RequestTaskManager?
@discardableResult
public func request(
    urlRequest: URLRequestConvertible,
    params: Parameters,
    dynamicParams: Parameters? = nil)
    -> RequestTaskManager?
{
    return RequestManager.default.request(urlRequest: urlRequest, params: params, dynamicParams: dynamicParams)
}

/// 取消请求
///
/// - Parameters:
///   - url: url
///   - params: 参数
///   - dynamicParams: 变化的参数，例如 时间戳-token 等
public func cancel(_ url: String, params: Parameters? = nil, dynamicParams: Parameters? = nil) {
    RequestManager.default.cancel(url, params: params, dynamicParams: dynamicParams)
}

/// 清除所有缓存
///
/// - Parameter completion: 完成回调
public func removeAllCache(completion: @escaping (Bool) -> ()) {
    RequestManager.default.removeAllCache(completion: completion)
}

/// 根据url和params清除缓存
///
/// - Parameters:
///   - url: url
///   - params: 参数
///   - dynamicParams: 变化的参数，例如 时间戳-token 等
///   - completion: 完成回调
public func removeObjectCache(_ url: String, params: [String: Any]? = nil, dynamicParams: Parameters? = nil, completion: @escaping (Bool) -> ()) {
    RequestManager.default.removeObjectCache(url, params: params, dynamicParams: dynamicParams, completion: completion)
}
