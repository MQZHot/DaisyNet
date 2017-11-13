//
//  CacheManager.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/17.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Foundation
import Cache

class CacheManager {
    static let `default` = CacheManager()
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
    /// 清除所有缓存
    ///
    /// - Parameter completion: 完成闭包
    func removeAllCache(completion: @escaping (Bool)->()) {
        storage?.async.removeAll(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion(true)
                case .error: completion(false)
                }
            }
        })
    }
    /// 根据key值清除缓存
    func removeObjectCache(_ cacheKey: String, completion: @escaping (Bool)->()) {
        storage?.async.removeObject(forKey: cacheKey, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion(true)
                case .error: completion(false)
                }
            }
        })
    }
    /// 异步读取缓存
    func object<T: Codable>(ofType type: T.Type, forKey key: String, completion: @escaping (Cache.Result<T>)->Void) {
        storage?.async.object(ofType: type, forKey: key, completion: completion)
    }
    /// 读取缓存
    func objectSync<T: Codable>(ofType type: T.Type, forKey key: String) -> T? {
        do {
            return (try storage?.object(ofType: type, forKey: key)) ?? nil
        } catch {
            return nil
        }
    }
    /// 异步存储
    func setObject<T: Codable>(_ object: T, forKey: String) {
        storage?.async.setObject(object, forKey: forKey, completion: { _ in
        })
    }
}
