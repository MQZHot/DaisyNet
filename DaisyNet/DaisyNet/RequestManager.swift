//
//  RequestManager.swift
//  DaisyNet
//
//  Created by MQZHot on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Foundation
import Alamofire

class RequestManager {
    static let `default` = RequestManager()
    private var requestTasks = [String: RequestTaskManager]()
    private var timeoutIntervalForRequest: TimeInterval? /// 超时时间
    
    func timeoutIntervalForRequest(_ timeInterval :TimeInterval) {
        self.timeoutIntervalForRequest = timeInterval
        RequestManager.default.timeoutIntervalForRequest = timeoutIntervalForRequest
    }
    
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
            if timeoutIntervalForRequest != nil {
                taskManager = RequestTaskManager().timeoutIntervalForRequest(timeoutIntervalForRequest!)
            } else {
                taskManager = RequestTaskManager()
            }
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
    
    func request(
        urlRequest: URLRequestConvertible,
        params: Parameters,
        dynamicParams: Parameters? = nil)
        -> RequestTaskManager? {
            if let urlStr = urlRequest.urlRequest?.url?.absoluteString {
                let components = urlStr.components(separatedBy: "?")
                if components.count > 0 {
                    let key = cacheKey(components.first!, params, dynamicParams)
                    var taskManager : RequestTaskManager?
                    if requestTasks[key] == nil {
                        if timeoutIntervalForRequest != nil {
                            taskManager = RequestTaskManager().timeoutIntervalForRequest(timeoutIntervalForRequest!)
                        } else {
                            taskManager = RequestTaskManager()
                        }
                        requestTasks[key] = taskManager
                    } else {
                        taskManager = requestTasks[key]
                    }
                    
                    taskManager?.completionClosure = {
                        self.requestTasks.removeValue(forKey: key)
                    }
                    var tempParam = params
                    let dynamicTempParam = dynamicParams==nil ? [:] : dynamicParams!
                    dynamicTempParam.forEach { (arg) in
                        tempParam[arg.key] = arg.value
                    }
                    taskManager?.request(urlRequest: urlRequest, cacheKey: key)
                    return taskManager!
                }
                return nil
            }
            return nil
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
public class RequestTaskManager {
    fileprivate var dataRequest: DataRequest?
    fileprivate var cache: Bool = false
    fileprivate var cacheKey: String!
    fileprivate var sessionManager: SessionManager?
    fileprivate var completionClosure: (()->())?
    
    @discardableResult
    fileprivate func timeoutIntervalForRequest(_ timeInterval :TimeInterval) -> RequestTaskManager {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeInterval
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        self.sessionManager = sessionManager
        return self
    }
    
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
        if sessionManager != nil {
            dataRequest = sessionManager?.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
        } else {
            dataRequest = Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
        }
        
        return self
    }
    
    
    /// request
    ///
    /// - Parameters:
    ///   - urlRequest: urlRequest
    ///   - cacheKey: cacheKey
    /// - Returns: RequestTaskManager
    @discardableResult
    fileprivate func request(
        urlRequest: URLRequestConvertible,
        cacheKey: String)
        -> RequestTaskManager {
            self.cacheKey = cacheKey
            if sessionManager != nil {
                dataRequest = sessionManager?.request(urlRequest)
            } else {
                dataRequest = Alamofire.request(urlRequest)
            }
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
    public func responseData(completion: @escaping (DaisyValue<Data>)->()) {
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
    public func responseString(completion: @escaping (DaisyValue<String>)->()) {
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
    public func responseJson(completion: @escaping (DaisyValue<Any>)->()) {
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
    fileprivate func response<T>(response: DataResponse<T>, completion: @escaping (DaisyValue<T>)->()) {
        responseCache(response: response) { (result) in
            completion(result)
        }
    }
    /// isCacheData
    fileprivate func responseCache<T>(response: DataResponse<T>, completion: @escaping (DaisyValue<T>)->()) {
        if completionClosure != nil { completionClosure!() }
        let result = DaisyValue(isCacheData: false, result: response.result, response: response.response)
        if openResultLog {
            DaisyLog("================请求数据=====================")
        }
        if openUrlLog {
            DaisyLog(response.request?.url?.absoluteString ?? "")
        }
        switch response.result {
        case .success(_):
            if openResultLog {
                if let data = response.data,
                    let str = String(data: data, encoding: .utf8) {
                    DaisyLog(str)
                }
            }
            if self.cache {/// 写入缓存
                var model = CacheModel()
                model.data = response.data
                CacheManager.default.setObject(model, forKey: self.cacheKey)
            }
        case .failure(let error):
            if openResultLog {
                DaisyLog(error.localizedDescription)
            }
        }
        completion(result)
    }
}
// MARK: - DaisyJsonResponse
public class DaisyJsonResponse: DaisyResponse {
    /// 响应JSON
    func responseJson(completion: @escaping (DaisyValue<Any>)->()) {
        dataRequest.responseJSON(completionHandler: { response in
            self.response(response: response, completion: completion)
        })
    }
    fileprivate func responseCacheAndJson(completion: @escaping (DaisyValue<Any>)->()) {
        if cache { cacheJson(completion: { (json) in
            let res = DaisyValue(isCacheData: true, result: Alamofire.Result.success(json), response: nil)
            completion(res)
        }) }
        dataRequest.responseJSON { (response) in
            self.responseCache(response: response, completion: completion)
        }
    }
    /// 获取缓存json
    @discardableResult
    fileprivate func cacheJson(completion: @escaping (Any)->()) -> DaisyJsonResponse {
        if let data = CacheManager.default.objectSync(forKey: cacheKey)?.data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            if openResultLog {
                DaisyLog("=================缓存=====================")
                if let str = String(data: data, encoding: .utf8) {
                    DaisyLog(str)
                }
            }
            completion(json)
        } else {
            if openResultLog {
                DaisyLog("读取缓存失败")
            }
        }
        return self
    }
}
// MARK: - DaisyStringResponse
public class DaisyStringResponse: DaisyResponse {
    /// 响应String
    func responseString(completion: @escaping (DaisyValue<String>)->()) {
        dataRequest.responseString(completionHandler: { response in
            self.response(response: response, completion: completion)
        })
    }
    @discardableResult
    fileprivate func cacheString(completion: @escaping (String)->()) -> DaisyStringResponse {
        if let data = CacheManager.default.objectSync(forKey: cacheKey)?.data,
            let str = String(data: data, encoding: .utf8) {
            completion(str)
        } else {
            if openResultLog {
                DaisyLog("读取缓存失败")
            }
        }
        return self
    }
    fileprivate func responseCacheAndString(completion: @escaping (DaisyValue<String>)->()) {
        if cache { cacheString(completion: { str in
            let res = DaisyValue(isCacheData: true, result: Alamofire.Result.success(str), response: nil)
            completion(res)
        })}
        dataRequest.responseString { (response) in
            self.responseCache(response: response, completion: completion)
        }
    }
}
// MARK: - DaisyDataResponse
public class DaisyDataResponse: DaisyResponse {
    /// 响应Data
    func responseData(completion: @escaping (DaisyValue<Data>)->()) {
        dataRequest.responseData(completionHandler: { response in
            self.response(response: response, completion: completion)
        })
    }
    @discardableResult
    fileprivate func cacheData(completion: @escaping (Data)->()) -> DaisyDataResponse {
        if let data = CacheManager.default.objectSync(forKey: cacheKey)?.data {
            completion(data)
        } else {
            if openResultLog {
                DaisyLog("读取缓存失败")
            }
        }
        return self
    }
    fileprivate func responseCacheAndData(completion: @escaping (DaisyValue<Data>)->()) {
        if cache { cacheData(completion: { (data) in
            let res = DaisyValue(isCacheData: true, result: Alamofire.Result.success(data), response: nil)
            completion(res)
        }) }
        dataRequest.responseData { (response) in
            self.responseCache(response: response, completion: completion)
        }
    }
}
