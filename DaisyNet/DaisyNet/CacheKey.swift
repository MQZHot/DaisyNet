//
//  CacheKey.swift
//  DaisyNet
//
//  Created by MQZHot on 2017/10/29.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//

import Foundation
import Cache

/// 将参数字典转换成字符串后md5
func cacheKey(_ url: String, _ params: Dictionary<String, Any>?, _ dynamicParams: Dictionary<String, Any>?) -> String {
    guard let params = params else {
        return MD5(url)
    }
    guard let dynamicParams = dynamicParams else {
        if let stringData = try? JSONSerialization.data(withJSONObject: params, options: []),
            let paramString = String(data: stringData, encoding: String.Encoding.utf8) {
            let str = "\(url)" + "\(paramString)"
            return MD5(str)
        } else {
            return MD5(url)
        }
    }
    /// `params`中过滤掉`dynamicParams`中的参数
    let filterParams = params.filter { (key, _) -> Bool in
        return dynamicParams.contains(where: { (key1, _) -> Bool in
            return key != key1
        })
    }
    guard let stringData = try? JSONSerialization.data(withJSONObject: filterParams, options: []),
        let paramString = String(data: stringData, encoding: String.Encoding.utf8) else {
            return MD5(url)
    }
    let str = "\(url)" + "\(paramString)"
    return MD5(str)
}
