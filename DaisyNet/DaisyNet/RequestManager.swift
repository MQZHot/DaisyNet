//
//  RequestManager.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Foundation
import Alamofire
import Cache
// MARK: - RequestManager

class RequestManager {
    static let `default` = RequestManager()
    /// Manage storage
    private var storage: Storage?
    
    /// init
    init() {
        let diskConfig = DiskConfig(name: "DaisyCache")
        let memoryConfig = MemoryConfig(expiry: .never)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
        } catch {
            DaisyLog(error)
        }
    }
    
    func requestJson(_ url: String,
                     method: HTTPMethod = .get,
                     params: Parameters? = nil,
                     cache: Bool = false,
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: HTTPHeaders? = nil,
                     completion: @escaping (Result<Any>)->()) {
        
        let cacheKey = self.cacheKey(url: url, params: params)
        if cache {/// 读取缓存
            self.object(forKey: cacheKey) { cacheJson in
                DispatchQueue.main.async {/// 主线程
                    let result = Result(isCacheData: true, result: Alamofire.Result.success(cacheJson))
                    DaisyLog("========================================")
                    DaisyLog(cacheJson)
                    completion(result)
                }
            }
        }
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if cache {
                    self.setObject(response.data, forKey: cacheKey)
                }
                let result = Result(isCacheData: false, result: Alamofire.Result.success(value))
                DaisyLog("========================================")
                DaisyLog(value)
                completion(result)
            case .failure(let error):
                let result = Result<Any>(isCacheData: false, result: Alamofire.Result.failure(error))
                DaisyLog("========================================")
                DaisyLog(error)
                completion(result)
            }
        }
    }
    
    /// 清除所有缓存
    ///
    /// - Parameter completion: 完成闭包
    open func removeAllCache(completion: @escaping (Bool)->()) {
        storage?.async.removeAll(completion: { result in
            switch result {
            case .value: completion(true)
            case .error: completion(false)
            }
        })
    }
    
    /// 根据key值清除缓存
    ///
    /// - Parameters:
    ///   - forKey: key
    ///   - completion: 完成回调
    func removeObjectCache(forKey: String, completion: @escaping (Bool)->()) {
        storage?.async.removeObject(forKey: forKey, completion: { result in
            switch result {
            case .value: completion(true)
            case .error: completion(false)
            }
        })
    }
    
    /// 读取缓存
    private func object(forKey key: String, completion: @escaping (Any)->()) {
        storage?.async.object(ofType: Data.self, forKey: key, completion: { result in
            switch result {
            case .value(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    
                    completion(json)
                }
            case .error(let error):
                DaisyLog(error)
            }
        })
    }
    
    /// 异步存储
    private func setObject<T: Codable>(_ object: T, forKey: String) {
        storage?.async.setObject(object, forKey: forKey, completion: { result in
            switch result {
            case .value: DaisyLog("saved successfully")
            case .error(let error): DaisyLog(error)
            }
        })
    }
    
    /// 将参数字典转换成字符串
    private func cacheKey(url: String, params: Dictionary<String, Any>?) -> String {
        guard let params = params,
            let stringData = try? JSONSerialization.data(withJSONObject: params, options: []),
            let paramString = String(data: stringData, encoding: String.Encoding.utf8) else {
                return url
        }
        let str = "\(url)" + "\(paramString)"
        return str
    }
}

