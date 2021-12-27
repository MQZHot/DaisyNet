//
//  MainTableViewController.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/11.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Alamofire
import DaisyNet
import UIKit

class MainTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
    }

    @IBAction func clearCache(_ sender: UIBarButtonItem) {
        DaisyNet.removeAllCache { result in
            print(result ? "清理成功" : "清理失败")
        }
        
    }
}
