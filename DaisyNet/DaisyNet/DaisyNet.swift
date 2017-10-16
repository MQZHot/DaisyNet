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

// MARK: - request

/// request
///
/// - Parameters:
///   - url: url
///   - method: 默认.get
///   - params: 参数[String: Any]
///   - cache: 是否缓存,默认false
///   - encoding: encoding
///   - headers: headers
/// - Returns: RequestManager
func requestJson(
    _ url: String,
    method: HTTPMethod = .get,
    params: Parameters? = nil,
    cache: Bool = false,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil,
    completion: @escaping (Result<Any>)->())
{
    RequestManager.default.requestJson(url, method: method, params: params, cache: cache, encoding: encoding, headers: headers, completion: completion
    )
}

/// 清除缓存
///
/// - Parameter completion: 是否成功
func removeAllCache(completion: @escaping (Bool)->()) {
    RequestManager.default.removeAllCache { result in
        completion(result)
    }
}

// MARK: - 下载

/// download
///
/// - Parameters:
///   - url: url
///   - method: method
///   - parameters: parameters
///   - encoding: encoding
///   - headers: headers
/// - Returns: DownloadManager
func download(
    _ url: String,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)
    -> TaskManager
{
    return DownloadManager.default.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
}

/// 取消下载
///
/// - Parameter url: url
func downloadCancel(_ url: String) {
    DownloadManager.default.cancel(url)
}

/// 下载百分比
///
/// - Parameter url: url
/// - Returns: percent
func downloadPercent(_ url: String) -> Double {
    return DownloadManager.default.downloadPercent(url)
}

/// 删除下载
///
/// - Parameters:
///   - url: url
///   - completion: download success/failure
func downloadDelete(_ url: String) {
    DownloadManager.default.delete(url)
}

/// 下载状态
///
/// - Parameter url: url
/// - Returns: status
func downloadStatus(_ url: String) -> DownloadStatus {
    return DownloadManager.default.downloadStatus(url)
}

/// 下载完成后，文件所在位置
///
/// - Parameter url: url
/// - Returns: file URL
func downloadFilePath(_ url: String) -> URL? {
    return DownloadManager.default.downloadFilePath(url)
}

/// 下载中的进度
///
/// - Parameters:
///   - url: url
///   - progress: 进度
/// - Returns: taskManager
@discardableResult
func downloadProgress(_ url: String, progress: @escaping ((Double)->())) -> TaskManager? {
    return DownloadManager.default.downloadProgress(url, progress: progress)
}
