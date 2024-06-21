//
//  DaisyResponseData.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import Alamofire
import UIKit

// MARK: - DaisyResponseData

class DaisyResponseData: DaisyResponse {
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
                if DaisyNet.log_result,
                   let str = String(data: data, encoding: .utf8)
                {
                    DaisyLog(str)
                }
                if let cacheKey = self.cacheKey { /// 写入缓存
                    let model = CacheModel(data: data)
                    CacheManager.default.setObject(model, forKey: cacheKey)
                }
                completion(.success(data))
            case .failure(let error):
                if DaisyNet.log_result {
                    DaisyLog(error.localizedDescription)
                }
                completion(.failure(error))
            }
        })
    }
}
