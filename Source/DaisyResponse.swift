//
//  DaisyResponse.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import Alamofire
import UIKit

// MARK: - DaisyBaseResponse

class DaisyResponse {
    var dataRequest: DataRequest
    var cacheKey: String?
    
    init(dataRequest: DataRequest, cacheKey: String?) {
        self.dataRequest = dataRequest
        if let cacheKey = cacheKey, cacheKey.isEmpty == false {
            self.cacheKey = cacheKey
        }
    }
}
