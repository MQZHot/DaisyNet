//
//  DownloadCell.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/14.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var indexPath: IndexPath!
    typealias Closure = (IndexPath)->()
    var download: Closure?
    var delete: Closure?

    /// button状态
    func buttonStatus(_ status: DownloadStatus) -> String {
        switch status {
        case .suspend:
            return "开始"
        case .complete:
            return "播放"
        case .downloading:
            return "暂停"
        }
    }
    
    func updateCell(_ status: DownloadStatus, progress: Double) {
        playButton.setTitle(buttonStatus(status), for: .normal)
        progressView.progress = Float(progress)
        progressLabel.text = "\(progress)"
        deleteBtn.isEnabled = progress == 0 ? false : true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        if download != nil { download!(indexPath) }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if delete != nil { delete!(indexPath) }
    }
}
