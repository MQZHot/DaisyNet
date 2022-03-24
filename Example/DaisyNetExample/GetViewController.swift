//
//  GetViewController.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/10.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Alamofire
import DaisyNet
import UIKit

class GetViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var cacheTextView: UITextView!

    let urlStr = "https://api.snaptubebrowser.com/surf-api/content/guide/v2"
    let params: [String: Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        DaisyNet.openResultLog = true
        /// 20s过期
        DaisyNet.cacheExpiryConfig(expiry: DaisyExpiry.seconds(20))
        /// 10s超时
        DaisyNet.timeoutIntervalForRequest(10)

        DaisyNet.request(urlStr, params: params).cache(true).responseCacheAndString(queue: .main) { value in
            switch value.result {
            case .success(let string):
                print(Thread.current)
                if value.isCacheData {
                    self.cacheTextView.text = string
                } else {
                    self.textView.text = string
                }

            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func clearCache(_ sender: UIBarButtonItem) {
        DaisyNet.removeObjectCache(urlStr, params: params) { success in
            switch success {
            case true:
                self.cacheTextView.text = ""
            case false:
                print("false")
            }
        }
    }

    deinit {
        print("dealloc")
    }
}
