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
    init(dataRequest: DataRequest, cache: Bool, cacheKey: String) {
        self.dataRequest = dataRequest
        self.cache = cache
        self.cacheKey = cacheKey
    }
}
