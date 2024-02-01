//
//  DaisyResult.swift
//  DaisyNet
//
//  Created by MQZHot on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Alamofire
import Foundation

//// MARK: - Result

public struct DaisySuccessResult<Value> {
    public let isCacheData: Bool
    public let value: Value

    init(isCacheData: Bool, value: Value) {
        self.isCacheData = isCacheData
        self.value = value
    }
}

public enum DaisyResult<Value> {
    case success(DaisySuccessResult<Value>)
    case failure(AFError)
}

struct DaisyJsonSerializationError: Error {
    let message: String
}
