//
//  GetViewController.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/10.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import UIKit
class GetViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cacheTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "http://api.travels.app887.com/api/Articles.action"
        let params = ["keyword" : "", "npc" : "0", "opc" : "20", "type" : "热门视频", "uid" : "2321"]
        
        DaisyNet.requestJson(url, params: params, cache: true) { response in
            
            switch response.result {
            case .success(let value):
                
                if response.isCacheData {
                    self.cacheTextView.text = "\(value)"
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                        self.textView.text = "\(value)"
                    })
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        /*
         DaisyNet.requestJson(url, method: .post, cache: true) { response in
         
             switch response.result {
         
                 case .success(let value):
         
                 case .failure(let error):
         
             }
         }
         */
    }
    deinit {
        print("dealloc")
    }
}
