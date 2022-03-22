//
//  CacheKey.swift
//  DaisyNet
//
//  Created by MQZHot on 2017/10/29.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//

import Cache
import Foundation

/// 将参数字典转换成字符串后md5
func cacheKey(_ url: String, _ params: [String: Any]?, _ dynamicParams: [String: Any]?) -> String {
    /// #29 参数过滤bug
    /// 参数重复, `params`中过滤掉`dynamicParams`中的参数
    let params = params ?? [:]
    let dynamicParams = dynamicParams ?? [:]
    var filterParams: [String: Any] = [:]
    
    for param in params {
        let commonParam = dynamicParams.first(where: { $0.key == param.key })
        if commonParam == nil {
            filterParams[param.key] = param.value
        }
    }
    
    if filterParams.keys.count > 0 {
        let str = "\(url)" + "\(sort(filterParams))"
        return MD5(str)
    } else {
        return MD5(url)
    }
}

/// 参数排序生成字符串
func sort(_ parameters: [String: Any]?) -> String {
    var sortParams = ""
    if let params = parameters {
        let sortArr = params.keys.sorted { $0 < $1 }
        sortArr.forEach { str in
            if let value = params[str] {
                sortParams = sortParams.appending("\(str)=\(value)")
            } else {
                sortParams = sortParams.appending("\(str)=")
            }
        }
    }
    return sortParams
}
