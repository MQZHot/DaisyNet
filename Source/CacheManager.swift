//
//  CacheManager.swift
//  MQZHot
//
//  Created by MQZHot on 2017/10/17.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Cache
import Foundation

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

    public var isExpired: Bool {
        return expiry.isExpired
    }
}

struct CacheModel: Codable {
    let data: Data
}

class CacheManager: NSObject {
    static let `default` = CacheManager()
    /// Manage storage
    private var storage: Storage<String, CacheModel>?
    /// init
    override init() {
        super.init()
        expiryConfiguration()
    }

    var expiry: DaisyExpiry = .never
    
    func expiryConfiguration(expiry: DaisyExpiry = .never) {
        self.expiry = expiry
        let diskConfig = DiskConfig(
            name: "DaisyCache",
            expiry: expiry.expiry
        )
        let memoryConfig = MemoryConfig(expiry: expiry.expiry)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: CacheModel.self))
        } catch {
            DaisyLog(error)
        }
    }
    
    /// 清除所有缓存
    func removeAllCache(completion: ((_ isSuccess: Bool) -> ())? = nil) {
        storage?.async.removeAll(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion?(true)
                case .error: completion?(false)
                }
            }
        })
    }
    
    /// 根据key值清除缓存
    func removeObjectCache(_ cacheKey: String, completion: ((_ isSuccess: Bool) -> ())? = nil) {
        storage?.async.removeObject(forKey: cacheKey, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion?(true)
                case .error: completion?(false)
                }
            }
        })
    }
    
    /// 读取
    func objectSync(forKey key: String) -> CacheModel? {
        if let model = try? storage?.object(forKey: key) {
            /// 过期清除缓存
            if let isExpire = try? storage?.isExpiredObject(forKey: key),
                isExpire
            {
                removeObjectCache(key) { _ in }
                DaisyLog("读取缓存失败： - 缓存过期")
                return nil
            } else {
                DaisyLog("读取缓存成功")
                return model
            }
        } else {
            DaisyLog("读取缓存失败：- 无缓存")
            return nil
        }
    }
    
    /// 存储
    func setObject(_ object: CacheModel, forKey key: String) {
        storage?.async.setObject(object, forKey: key, expiry: nil, completion: { result in
            switch result {
            case .value:
                DaisyLog("缓存成功")
            case .error(let error):
                DaisyLog("缓存失败: \(error)")
            }
        })
    }
}
