//
//  UploadViewController.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/12/17.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import UIKit



class UploadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func photoBrowser(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }else{
            print("读取相册错误")
        }
    }
}
extension UploadViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
}
