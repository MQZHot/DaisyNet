//
//  DaisyJsonResponse.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import UIKit
import Alamofire

// MARK: - DaisyJsonResponse

class DaisyJsonResponse: DaisyResponse {
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
                if self.cache { /// 写入缓存
                    let model = CacheModel(data: data)
                    CacheManager.default.setObject(model, forKey: self.cacheKey)
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    let res = DaisySuccessResult(isCacheData: false, value: json)
                    completion(.success(res))
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
    
    func responseCacheAndJson(queue: DispatchQueue, completion: @escaping (DaisyResult<Any>)->()) {
        if cache {
            queue.async {
                if let json = self.cacheJson() {
                    let res = DaisySuccessResult(isCacheData: true, value: json)
                    completion(.success(res))
                }
            }
        }
        responseJson(queue: queue, completion: completion)
    }

    /// 获取缓存json
    @discardableResult
    func cacheJson()->Any? {
        if let data = CacheManager.default.objectSync(forKey: cacheKey)?.data,
           let json = try? JSONSerialization.jsonObject(with: data, options: [])
        {
            return json
        }
        return nil
    }
}
