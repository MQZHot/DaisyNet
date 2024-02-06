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

        DaisyNet.log_result = true
        /// 20s过期
        DaisyNet.cacheExpiryConfig(expiry: DaisyExpiry.seconds(20))

        DaisyNet.request(urlStr, params: params).cache(true).responseCacheAndString(queue: .main) { value in
            switch value {
            case .success(let result):
                print(Thread.current)
                if result.isCacheData {
                    self.cacheTextView.text = result.value
                } else {
                    self.textView.text = result.value
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
