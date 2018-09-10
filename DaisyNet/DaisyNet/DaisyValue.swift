//
//  DaisyValue.swift
//  DaisyNet
//
//  Created by MQZHot on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Foundation
import Alamofire


//// MARK: - Result
public struct DaisyValue<Value> {
    public let isCacheData: Bool
    public let result: Alamofire.Result<Value>
    public let response: HTTPURLResponse?
    init(isCacheData: Bool, result: Alamofire.Result<Value>, response: HTTPURLResponse?) {
        self.isCacheData = isCacheData
        self.result = result
        self.response = response
    }
}

func getSystemTimestamp() -> Double {
    let date = Date()
    let time = String(format: "%.3f", date.timeIntervalSince1970)
    let timeSp = time.replacingOccurrences(of: ".", with: "") as NSString
    return timeSp.doubleValue
}
