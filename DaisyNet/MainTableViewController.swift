//
//  MainTableViewController.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/11.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import UIKit
import Alamofire
class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print(NSHomeDirectory())
        Alamofire.upload(Data(), to: "").uploadProgress { (pro) in
            
            }.responseJSON { (response) in
                
        }
    }
    
    @IBAction func clearCache(_ sender: UIBarButtonItem) {
        DaisyNet.removeAllCache { result in
            print(result ? "清理成功" : "清理失败")
        }
    }
    
}
