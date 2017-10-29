//
//  DaisyValue.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Foundation
import Alamofire


//// MARK: - Result
public struct DaisyValue<Value> {
    public let isCacheData: Bool
    public let result: Alamofire.Result<Value>
    init(isCacheData: Bool, result: Alamofire.Result<Value>) {
        self.isCacheData = isCacheData
        self.result = result
    }
}

