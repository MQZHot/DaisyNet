//
//  DaisyDataResponse.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import UIKit
import Alamofire

// MARK: - DaisyDataResponse

class DaisyDataResponse: DaisyResponse {
    /// 响应Data
    func responseData(queue: DispatchQueue, completion: @escaping (DaisyResult<Data>)->()) {
        dataRequest.responseData(queue: queue, completionHandler: { response in
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
                let res = DaisySuccessResult(isCacheData: false, value: data)
                completion(.success(res))
            case .failure(let error):
                if DaisyNet.log_result {
                    DaisyLog(error.localizedDescription)
                }
                completion(.failure(error))
            }
            self.completionClosure?()
            self.completionClosure = nil
        })
    }

    @discardableResult
    func cacheData()->Data? {
        if let data = CacheManager.default.objectSync(forKey: cacheKey)?.data {
            return data
        }
        return nil
    }

    func responseCacheAndData(queue: DispatchQueue, completion: @escaping (DaisyResult<Data>)->()) {
        if cache {
            queue.async {
                if let data = self.cacheData() {
                    let res = DaisySuccessResult(isCacheData: true, value: data)
                    completion(.success(res))
                }
            }
        }
        responseData(queue: queue, completion: completion)
    }
}
