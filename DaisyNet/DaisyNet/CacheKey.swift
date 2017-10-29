//
//  CacheKey.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/29.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Foundation
import Cache
/// 将参数字典转换成字符串后md5
func cacheKey(_ url: String, _ params: Dictionary<String, Any>?) -> String {
    guard let params = params,
        let stringData = try? JSONSerialization.data(withJSONObject: params, options: []),
        let paramString = String(data: stringData, encoding: String.Encoding.utf8) else {
            return MD5(url)
    }
    let str = "\(url)" + "\(paramString)"
    return MD5(str)
}
