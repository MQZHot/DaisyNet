//
//  DaisyNet.swift
//  ZoneHot
//
//  Created by mengqingzheng on 2017/10/10.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import UIKit
import Alamofire
import Cache

// MARK: - 网络请求

/// 网络请求
///
/// - Parameters:
///   - url: url
///   - method: .get .post ... 默认.get
///   - params: 参数字典
///   - encoding: 编码方式
///   - headers: 请求头
/// - Returns:
@discardableResult
public func request(
    _ url: String,
    method: HTTPMethod = .get,
    params: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    -> RequestTaskManager
{
    return RequestManager.default.request(url, method: method, params: params, encoding: encoding, headers: headers)
}

/// 取消请求
public func cancel(_ url: String, params: Parameters? = nil) {
    RequestManager.default.cancel(url, params: params)
}

/// 清除所有缓存
public func removeAllCache(completion: @escaping (Bool)->()) {
    RequestManager.default.removeAllCache(completion: completion)
}

/// 根据url和params清除缓存
public func removeObjectCache(_ url: String, params: [String: Any]? = nil, completion: @escaping (Bool)->()) {
    RequestManager.default.removeObjectCache(url, params: params, completion: completion)
}

protocol RequestProtocol {
    /// 是否缓存数据
    func cache(_ cache: Bool) -> RequestTaskManager
    /// 获取缓存Data
    @discardableResult
    func cacheData(completion: @escaping (Data)->()) -> DaisyDataResponse
    /// 响应Data
    func responseData(completion: @escaping (Alamofire.Result<Data>)->())
    /// 先获取Data缓存，再响应Data
    func responseCacheAndData(completion: @escaping (DaisyValue<Data>)->())
    /// 获取缓存String
    @discardableResult
    func cacheString(completion: @escaping (String)->()) -> DaisyStringResponse
    /// 响应String
    func responseString(completion: @escaping (Alamofire.Result<String>)->())
    /// 先获取缓存String,再响应String
    func responseCacheAndString(completion: @escaping (DaisyValue<String>)->())
    /// 获取缓存JSON
    @discardableResult
    func cacheJson(completion: @escaping (Any)->()) -> DaisyJsonResponse
    /// 响应JSON
    func responseJson(completion: @escaping (Alamofire.Result<Any>)->())
    /// 先获取缓存JSON，再响应JSON
    func responseCacheAndJson(completion: @escaping (DaisyValue<Any>)->())
}
protocol DaisyJsonResponseProtocol {
    /// 响应JSON
    func responseJson(completion: @escaping (Alamofire.Result<Any>)->())
}
protocol DaisyDataResponseProtocol {
    /// 响应Data
    func responseData(completion: @escaping (Alamofire.Result<Data>)->())
}
protocol DaisyStringResponseProtocol {
    /// 响应String
    func responseString(completion: @escaping (Alamofire.Result<String>)->())
}

// MARK: - 下载

/// 下载
@discardableResult
public func download(
    _ url: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    -> DownloadTaskManager
{
    return DownloadManager.default.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
}

/// 取消下载
///
/// - Parameter url: url
public func downloadCancel(_ url: String) {
    DownloadManager.default.cancel(url)
}

/// 下载百分比
///
/// - Parameter url: url
/// - Returns: percent
public func downloadPercent(_ url: String) -> Double {
    return DownloadManager.default.downloadPercent(url)
}

/// 删除某个下载
///
/// - Parameters:
///   - url: url
///   - completion: download success/failure
public func downloadDelete(_ url: String) {
    DownloadManager.default.delete(url)
}

/// 下载状态
///
/// - Parameter url: url
/// - Returns: status
public func downloadStatus(_ url: String) -> DownloadStatus {
    return DownloadManager.default.downloadStatus(url)
}

/// 下载完成后，文件所在位置
///
/// - Parameter url: url
/// - Returns: file URL
public func downloadFilePath(_ url: String) -> URL? {
    return DownloadManager.default.downloadFilePath(url)
}

/// 下载中的进度,任务下载中时，退出当前页面,再次进入时继续下载
///
/// - Parameters:
///   - url: url
///   - progress: 进度
/// - Returns: taskManager
@discardableResult
public func downloadProgress(_ url: String, progress: @escaping ((Double)->())) -> DownloadTaskManager? {
    return DownloadManager.default.downloadProgress(url, progress: progress)
}
