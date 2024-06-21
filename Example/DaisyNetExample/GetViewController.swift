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

    let urlStr = "https://www.youtube.com"
    let params: [String: Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        DaisyNet.log_result = true
        /// 20s过期
//        DaisyNet.cacheExpiryConfig(expiry: DaisyExpiry.seconds(20))

        /// 缓存存在
//        DaisyNet.cacheDataIsExist(with: <#T##String?#>)
        
        /// 缓存标识
        let identifier = "home"
        
        /// 读取缓存
        let cacheString = DaisyNet.cacheString(with: identifier)
        let cacheData = DaisyNet.cacheData(with: identifier)
        let cacheJson = DaisyNet.cacheJson(with: identifier)
        
        /// 网络请求
        DaisyNet.request(urlStr, params: params).cacheIdentifier(identifier).responseString(queue: .main) { result in
            switch result {
            case .success(let string):
                self.textView.text = string
                print(Thread.current)
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func clearCache(_ sender: UIBarButtonItem) {
        DaisyNet.removeCache(with: "home") { success in
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
