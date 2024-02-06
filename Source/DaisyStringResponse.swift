//
//  DaisyStringResponse.swift
//  DaisyNet
//
//  Created by pro big on 2024/2/1.
//

import Alamofire
import UIKit

// MARK: - DaisyStringResponse

class DaisyStringResponse: DaisyResponse {
    /// 响应String
    func responseString(queue: DispatchQueue, completion: @escaping (DaisyResult<String>)->()) {
        dataRequest.responseString(queue: queue, completionHandler: { response in
            if DaisyNet.log_result {
                DaisyLog("================请求数据=====================")
            }
            if DaisyNet.log_url {
                DaisyLog(response.request?.url?.absoluteString ?? "")
            }
            switch response.result {
            case .success(let string):
                if DaisyNet.log_result {
                    DaisyLog(string)
                }
                if self.cache, let data = response.data { /// 写入缓存
                    let model = CacheModel(data: data)
                    CacheManager.default.setObject(model, forKey: self.cacheKey)
                }
                let res = DaisySuccessResult(isCacheData: false, value: string)
                completion(.success(res))
            case .failure(let error):
                if DaisyNet.log_result {
                    DaisyLog(error.localizedDescription)
                }
                completion(.failure(error))
            }
        })
    }

    @discardableResult
    func cacheString()->String? {
        if let data = CacheManager.default.objectSync(forKey: cacheKey)?.data,
           let str = String(data: data, encoding: .utf8)
        {
            return str
        }
        return nil
    }

    func responseCacheAndString(queue: DispatchQueue, completion: @escaping (DaisyResult<String>)->()) {
        if cache {
            queue.async {
                if let str = self.cacheString() {
                    let res = DaisySuccessResult(isCacheData: true, value: str)
                    completion(.success(res))
                }
            }
        }
        responseString(queue: queue, completion: completion)
    }
}
