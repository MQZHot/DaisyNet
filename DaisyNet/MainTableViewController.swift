//
//  MainTableViewController.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/11.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print(NSHomeDirectory())
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func clearCache(_ sender: UIBarButtonItem) {
        DaisyNet.removeAllCache { result in
            print(result ? "清理成功" : "清理失败")
        }
    }
    
}
