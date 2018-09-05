//
//  CacheManager.swift
//  MQZHot
//
//  Created by MQZHot on 2017/10/17.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Foundation
import Cache

struct CacheModel: Codable {
    var data: Data?
    var dataDict: Dictionary<String, Data>?
    init() { }
}

public enum DaisyExpiry {
    /// Object will be expired in the nearest future
    case never
    /// Object will be expired in the specified amount of seconds
    case seconds(TimeInterval)
    /// Object will be expired on the specified date
    case date(Date)
    
    /// Returns the appropriate date object
    public var expiry: Expiry {
        switch self {
        case .never:
            return Expiry.never
        case .seconds(let seconds):
            return Expiry.seconds(seconds)
        case .date(let date):
            return Expiry.date(date)
        }
    }
}

class CacheManager {
    static let `default` = CacheManager()
    /// Manage storage
    private var storage: Storage<CacheModel>?
    /// init
    init() {
        expiryConfiguration()
    }
    
    func expiryConfiguration(disk: DaisyExpiry = .never, memory: DaisyExpiry = .never) {
        let diskConfig = DiskConfig(
            name: "DaisyCache",
            expiry: disk.expiry
        )
        let memoryConfig = MemoryConfig(expiry: memory.expiry)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: CacheModel.self))
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
    func object(forKey key: String, completion: @escaping (Cache.Result<CacheModel>)->Void) {
        storage?.async.object(forKey: key, completion: completion)
    }
    /// 读取缓存
    func objectSync(forKey key: String) -> CacheModel? {
        do {
            return (try storage?.object(forKey: key)) ?? nil
        } catch {
            return nil
        }
    }
    /// 异步存储
    func setObject(_ object: CacheModel, forKey: String) {
        storage?.async.setObject(object, forKey: forKey, completion: { _ in
        })
    }
}
