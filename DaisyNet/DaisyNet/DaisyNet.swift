//
//  DaisyNet.swift
//  ZoneHot
//
//  Created by MQZHot on 2017/10/10.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//

import UIKit
import Alamofire
import Cache

// MARK: - 网络请求

/// 统一设置超时时间
///
/// - Parameter timeInterval: 超时时间
public func timeoutIntervalForRequest(_ timeInterval :TimeInterval) {
    RequestManager.default.timeoutIntervalForRequest(timeInterval)
}

/// 开启/关闭请求url log
public var openUrlLog: Bool = true
/// 开启/关闭结果log
public var openResultLog: Bool = true


/// 网络请求
///
/// - Parameters:
///   - url: url
///   - method: .get .post ... 默认.get
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
public func removeAllCache(completion: @escaping (Bool)->()) {
    RequestManager.default.removeAllCache(completion: completion)
}

/// 根据url和params清除缓存
///
/// - Parameters:
///   - url: url
///   - params: 参数
///   - dynamicParams: 变化的参数，例如 时间戳-token 等
///   - completion: 完成回调
public func removeObjectCache(_ url: String, params: [String: Any]? = nil, dynamicParams: Parameters? = nil, completion: @escaping (Bool)->()) {
    RequestManager.default.removeObjectCache(url, params: params,dynamicParams: dynamicParams, completion: completion)
}

// MARK: - 下载

/// 文件下载
///
/// - Parameters:
///   - url: url
///   - method: .get .post ... 默认.get
///   - parameters: 参数
///   - dynamicParams: 变化的参数，例如 时间戳-token 等
///   - encoding: 编码方式
///   - headers: 请求头
///   - fileName: 自定义文件名，需要带文件扩展名
/// - Returns: DownloadTaskManager
public func download(
    _ url: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    dynamicParams: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    fileName: String? = nil)
    ->DownloadTaskManager
{
    return DownloadManager.default.download(url, method: method, parameters: parameters, dynamicParams: dynamicParams, encoding: encoding, headers: headers, fileName: fileName)
}

/// 取消下载
///
/// - Parameter url: url
public func downloadCancel(_ url: String, parameters: Parameters? = nil, dynamicParams: Parameters? = nil) {
    DownloadManager.default.cancel(url, parameters: parameters, dynamicParams: dynamicParams)
}

/// Cancel all download tasks
public func downloadCancelAll() {
    DownloadManager.default.cancelAll();
}

/// 下载百分比
///
/// - Parameter url: url
/// - Returns: percent
public func downloadPercent(_ url: String, parameters: Parameters? = nil, dynamicParams: Parameters? = nil) -> Double {
    return DownloadManager.default.downloadPercent(url, parameters: parameters, dynamicParams: dynamicParams)
}

/// 删除某个下载
///
/// - Parameters:
///   - url: url
///   - completion: download success/failure
public func downloadDelete(_ url: String, parameters: Parameters? = nil,dynamicParams: Parameters? = nil, completion: @escaping (Bool)->()) {
    DownloadManager.default.delete(url,parameters: parameters,dynamicParams: dynamicParams, completion: completion)
}

/// 下载状态
///
/// - Parameter url: url
/// - Returns: status
public func downloadStatus(_ url: String, parameters: Parameters? = nil,dynamicParams: Parameters? = nil) -> DownloadStatus {
    return DownloadManager.default.downloadStatus(url, parameters: parameters,dynamicParams: dynamicParams)
}

/// 下载完成后，文件所在位置
///
/// - Parameter url: url
/// - Returns: file URL
public func downloadFilePath(_ url: String, parameters: Parameters? = nil,dynamicParams: Parameters? = nil) -> URL? {
    return DownloadManager.default.downloadFilePath(url, parameters: parameters,dynamicParams: dynamicParams)
}

/// 下载中的进度,任务下载中时，退出当前页面,再次进入时继续下载
///
/// - Parameters:
///   - url: url
///   - progress: 进度
/// - Returns: taskManager
@discardableResult
public func downloadProgress(_ url: String, parameters: Parameters? = nil,dynamicParams: Parameters? = nil, progress: @escaping ((Double)->())) -> DownloadTaskManager? {
    return DownloadManager.default.downloadProgress(url, parameters: parameters,dynamicParams: dynamicParams, progress: progress)
}
