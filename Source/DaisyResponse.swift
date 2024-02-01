//
//  DaisyResponse.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import UIKit
import Alamofire

// MARK: - DaisyBaseResponse

class DaisyResponse {
    var dataRequest: DataRequest
    var cache: Bool
    var cacheKey: String
    var completionClosure: (()->())?
    init(dataRequest: DataRequest, cache: Bool, cacheKey: String, completionClosure: (()->())?) {
        self.dataRequest = dataRequest
        self.cache = cache
        self.cacheKey = cacheKey
        self.completionClosure = completionClosure
    }
}
