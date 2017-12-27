//
//  RequestManager.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Foundation
import Alamofire
// MARK: - RequestManager

class RequestManager {
    static let `default` = RequestManager()
    private var requestTasks = [String: RequestTaskManager]()
    
    func request(
        _ url: String,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        dynamicParams: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> RequestTaskManager
    {
        let key = cacheKey(url, params, dynamicParams)
        var taskManager : RequestTaskManager?
        if requestTasks[key] == nil {
            taskManager = RequestTaskManager()
            requestTasks[key] = taskManager
        } else {
            taskManager = requestTasks[key]
        }
        taskManager?.completionClosure = {
            self.requestTasks.removeValue(forKey: key)
        }
        var tempParam = params==nil ? [:] : params!
        let dynamicTempParam = dynamicParams==nil ? [:] : dynamicParams!
        dynamicTempParam.forEach { (arg) in
            tempParam[arg.key] = arg.value
        }
        taskManager?.request(url, method: method, params: tempParam, cacheKey: key, encoding: encoding, headers: headers)
        return taskManager!
    }
    
    /// 取消请求
    func cancel(_ url: String, params: Parameters? = nil, dynamicParams: Parameters? = nil) {
        let key = cacheKey(url, params, dynamicParams)
        let taskManager = requestTasks[key]
        taskManager?.dataRequest?.cancel()
    }
    
    /// 清除所有缓存
    func removeAllCache(completion: @escaping (Bool)->()) {
        CacheManager.default.removeAllCache(completion: completion)
    }
    
    /// 根据key值清除缓存
    func removeObjectCache(_ url: String, params: [String: Any]? = nil, dynamicParams: Parameters? = nil,  completion: @escaping (Bool)->()) {
        let key = cacheKey(url, params, dynamicParams)
        CacheManager.default.removeObjectCache(key, completion: completion)
    }
}

// MARK: - 请求任务
public class RequestTaskManager: RequestProtocol {
    fileprivate var dataRequest: DataRequest?
    fileprivate var cache: Bool = false
    fileprivate var cacheKey: String!
    fileprivate var completionClosure: (()->())?
    
    @discardableResult
    fileprivate func request(
        _ url: String,
        method: HTTPMethod = .get,
        params: Parameters? = nil,
        cacheKey: String,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> RequestTaskManager
    {
        self.cacheKey = cacheKey
        dataRequest = Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
        return self
    }
    /// 是否缓存数据
    public func cache(_ cache: Bool) -> RequestTaskManager {
        self.cache = cache
        return self
    }
    
    /// 获取缓存Data
    @discardableResult
    public func cacheData(completion: @escaping (Data)->()) -> DaisyDataResponse {
        let dataResponse = DaisyDataResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        return dataResponse.cacheData(completion: completion)
    }
    /// 响应Data
    public func responseData(completion: @escaping (Alamofire.Result<Data>)->()) {
        let dataResponse = DaisyDataResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        dataResponse.responseData(completion: completion)
    }
    /// 先获取Data缓存，再响应Data
    public func responseCacheAndData(completion: @escaping (DaisyValue<Data>)->()) {
        let dataResponse = DaisyDataResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        dataResponse.responseCacheAndData(completion: completion)
    }
    /// 获取缓存String
    @discardableResult
    public func cacheString(completion: @escaping (String)->()) -> DaisyStringResponse {
        let stringResponse = DaisyStringResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        return stringResponse.cacheString(completion:completion)
    }
    /// 响应String
    public func responseString(completion: @escaping (Alamofire.Result<String>)->()) {
        let stringResponse = DaisyStringResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        stringResponse.responseString(completion: completion)
    }
    /// 先获取缓存String,再响应String
    public func responseCacheAndString(completion: @escaping (DaisyValue<String>)->()) {
        let stringResponse = DaisyStringResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        stringResponse.responseCacheAndString(completion: completion)
    }
    /// 获取缓存JSON
    @discardableResult
    public func cacheJson(completion: @escaping (Any)->()) -> DaisyJsonResponse {
        let jsonResponse = DaisyJsonResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        return jsonResponse.cacheJson(completion:completion)
    }
    /// 响应JSON
    public func responseJson(completion: @escaping (Alamofire.Result<Any>)->()) {
        let jsonResponse = DaisyJsonResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        jsonResponse.responseJson(completion: completion)
    }
    /// 先获取缓存JSON，再响应JSON
    public func responseCacheAndJson(completion: @escaping (DaisyValue<Any>)->()) {
        let jsonResponse = DaisyJsonResponse(dataRequest: dataRequest!, cache: cache, cacheKey: cacheKey, completionClosure: completionClosure)
        jsonResponse.responseCacheAndJson(completion: completion)
    }
}
// MARK: - DaisyBaseResponse
public class DaisyResponse {
    fileprivate var dataRequest: DataRequest
    fileprivate var cache: Bool
    fileprivate var cacheKey: String
    fileprivate var completionClosure: (()->())?
    fileprivate init(dataRequest: DataRequest, cache: Bool, cacheKey: String, completionClosure: (()->())?) {
        self.dataRequest = dataRequest
        self.cache = cache
        self.cacheKey = cacheKey
        self.completionClosure = completionClosure
    }
    ///
    fileprivate func response<T>(response: DataResponse<T>, completion: @escaping (Alamofire.Result<T>)->()) {
        responseCache(response: response) { (result) in
            completion(result.result)
        }
    }
    /// isCacheData
    fileprivate func responseCache<T>(response: DataResponse<T>, completion: @escaping (DaisyValue<T>)->()) {
        if completionClosure != nil { completionClosure!() }
        let result = DaisyValue(isCacheData: false, result: response.result)
        DaisyLog("========================================")
        switch response.result {
        case .success(let value): DaisyLog(value)
        if self.cache {/// 写入缓存
            CacheManager.default.setObject(response.data, forKey: self.cacheKey)
            }
        case .failure(let error): DaisyLog(error.localizedDescription)
        }
        completion(result)
    }
}
// MARK: - DaisyJsonResponse
public class DaisyJsonResponse: DaisyResponse , DaisyJsonResponseProtocol {
    /// 响应JSON
    func responseJson(completion: @escaping (Alamofire.Result<Any>)->()) {
        dataRequest.responseJSON(completionHandler: { response in
            self.response(response: response, completion: completion)
        })
    }
    fileprivate func responseCacheAndJson(completion: @escaping (DaisyValue<Any>)->()) {
        if cache { cacheJson(completion: { (json) in
            let res = DaisyValue(isCacheData: true, result: Alamofire.Result.success(json))
            completion(res)
        }) }
        dataRequest.responseJSON { (response) in
            self.responseCache(response: response, completion: completion)
        }
    }
    @discardableResult
    fileprivate func cacheJson(completion: @escaping (Any)->()) -> DaisyJsonResponse {
        CacheManager.default.object(ofType: Data.self, forKey: cacheKey) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .value(let data):
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        DispatchQueue.main.async {/// 主线程
                            DaisyLog("========================================")
                            DaisyLog(json)
                            completion(json)
                        }
                    }
                case .error(_):
                    DaisyLog("读取缓存失败")
                }
            }
        }
        return self
    }
}
// MARK: - DaisyStringResponse
public class DaisyStringResponse: DaisyResponse, DaisyStringResponseProtocol {
    /// 响应String
    func responseString(completion: @escaping (Alamofire.Result<String>)->()) {
        dataRequest.responseString(completionHandler: { response in
            self.response(response: response, completion: completion)
        })
    }
    @discardableResult
    fileprivate func cacheString(completion: @escaping (String)->()) -> DaisyStringResponse {
        CacheManager.default.object(ofType: Data.self, forKey: cacheKey) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .value(let data):
                    if let str = String(data: data, encoding: .utf8) {
                        completion(str)
                    }
                case .error(_):
                   DaisyLog("读取缓存失败")
                }
            }
        }
        return self
    }
    fileprivate func responseCacheAndString(completion: @escaping (DaisyValue<String>)->()) {
        if cache { cacheString(completion: { str in
            let res = DaisyValue(isCacheData: true, result: Alamofire.Result.success(str))
            completion(res)
        })}
        dataRequest.responseString { (response) in
            self.responseCache(response: response, completion: completion)
        }
    }
}
// MARK: - DaisyDataResponse
public class DaisyDataResponse: DaisyResponse, DaisyDataResponseProtocol {
    /// 响应Data
    func responseData(completion: @escaping (Alamofire.Result<Data>)->()) {
        dataRequest.responseData(completionHandler: { response in
            self.response(response: response, completion: completion)
        })
    }
    @discardableResult
    fileprivate func cacheData(completion: @escaping (Data)->()) -> DaisyDataResponse {
        CacheManager.default.object(ofType: Data.self, forKey: cacheKey) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .value(let data):
                    completion(data)
                case .error(_):
                    DaisyLog("读取缓存失败")
                }
            }
        }
        return self
    }
    fileprivate func responseCacheAndData(completion: @escaping (DaisyValue<Data>)->()) {
        if cache { cacheData(completion: { (data) in
            let res = DaisyValue(isCacheData: true, result: Alamofire.Result.success(data))
            completion(res)
        }) }
        dataRequest.responseData { (response) in
            self.responseCache(response: response, completion: completion)
        }
    }
}
