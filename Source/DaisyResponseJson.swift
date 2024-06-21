//
//  DaisyResponseJson.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import Alamofire
import UIKit

// MARK: - DaisyResponseJson

class DaisyResponseJson: DaisyResponse {
    /// 响应JSON
    func responseJson(queue: DispatchQueue, completion: @escaping (DaisyResult<Any>)->()) {
        dataRequest.responseData(queue: queue) { response in
            if DaisyNet.log_result {
                DaisyLog("================请求数据=====================")
            }
            if DaisyNet.log_url {
                DaisyLog(response.request?.url?.absoluteString ?? "")
            }
            switch response.result {
            case .success(let data):
                if DaisyNet.log_result {
                    if let str = String(data: data, encoding: .utf8) {
                        DaisyLog(str)
                    }
                }
                if let cacheKey = self.cacheKey { /// 写入缓存
                    let model = CacheModel(data: data)
                    CacheManager.default.setObject(model, forKey: cacheKey)
                }

                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    completion(.success(json))
                } else {
                    let error = AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: DaisyJsonSerializationError(message: "jsonSerialization Failed")))
                    completion(.failure(error))
                }
            case .failure(let error):
                if DaisyNet.log_result {
                    DaisyLog(error.localizedDescription)
                }
                completion(.failure(error))
            }
        }
    }
}
