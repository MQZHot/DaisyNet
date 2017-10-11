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

class DaisyNet {
    
    private var storage: Storage?
    
    init() {
        let diskConfig = DiskConfig(name: "ZCache")
        let memoryConfig = MemoryConfig(expiry: .never)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
        } catch {
            DaisyLog(error)
        }
    }
    
    open func request(_ url: String,
                       method: HTTPMethod = .get,
                       params: Dictionary<String, Any>?,
                       cache: Bool = false,
                       completion: @escaping (Alamofire.Result<Any>)->()) {
        let cacheKey = self.cacheKey(url: url, params: params)
        if cache {
            self.object(forKey: cacheKey) { cacheJson in
                completion(Alamofire.Result.success(cacheJson))
            }
        }
        
        Alamofire.request(url, method: method, parameters: params).responseJSON { response in
            switch response.result {
            case .success(let value):
                if cache {
                    self.setObject(response.data, forKey: cacheKey)
                }
                completion(Alamofire.Result.success(value))
            case .failure(let error):
                completion(Alamofire.Result.failure(error))
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

public enum Effect<Value> {
    case success(Value)
    case failure(Error)
    
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - log日志
func DaisyLog<T>( _ message: T, file: String = #file, method: String = #function, line: Int = #line){
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

