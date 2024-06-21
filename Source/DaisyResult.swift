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

public enum DaisyResult<Value> {
    case success(Value)
    case failure(AFError)
}

struct DaisyJsonSerializationError: Error {
    let message: String
}
