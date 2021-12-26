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
    /// c参数重复, `params`中过滤掉`dynamicParams`中的参数
    if let filterParams = params?.filter({ key, _ -> Bool in
        dynamicParams?.contains(where: { key1, _ -> Bool in
            key != key1
        }) ?? false
    }) {
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
