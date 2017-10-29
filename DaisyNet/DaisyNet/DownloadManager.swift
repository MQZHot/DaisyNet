//
//  DownloadManager.swift
//  DaisyNet
//
//  Created by mengqingzheng on 2017/10/12.
//  Copyright © 2017年 MQZHot. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - downloadManager
class DownloadManager {
    static let `default` = DownloadManager()
    /// 下载任务管理
    fileprivate var downloadTasks = [String: DownloadTaskManager]()
    
    @discardableResult
    func download(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DownloadTaskManager
    {
        let taskManager = DownloadTaskManager()
        taskManager.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        downloadTasks[url] = taskManager
        taskManager.cancelCompletion = {
            self.downloadTasks.removeValue(forKey: url)
        }
        return taskManager
    }
    /// 暂停下载
    func cancel(_ url: String) {
        let task = downloadTasks[url]
        task?.downloadRequest?.cancel()
        task?.cancelCompletion = {
            self.downloadTasks.removeValue(forKey: url)
        }
    }
    /// 删除单个下载
    func delete(_ url: String) {
        let task = downloadTasks[url]
        task?.downloadStatus = .suspend
        task?.downloadRequest?.cancel()
        delete(task: task, url: url)
        task?.cancelCompletion = {
            self.delete(task: task, url: url)
        }
    }
    
    private func delete(task: DownloadTaskManager?, url: String) {
        if let path = downloadPlist[url] as? String {
            let fileURL = cacheDirectory().appendingPathComponent("Download/\(path)")
            do {
                try FileManager.default.removeItem(at: fileURL)
                DaisyLog("删除成功")
            } catch {
                DaisyLog("删除失败")
            }
        }
        downloadTasks.removeValue(forKey: url)
        dataPlist.removeObject(forKey: url)
        downloadPlist.removeObject(forKey: url)
        progressPlist.removeObject(forKey: url)
        dataPlist.write(to: dataPath, atomically: true)
        progressPlist.write(to: progressPath, atomically: true)
        downloadPlist.write(to: downloadPath, atomically: true)
    }
    /// 下载完成路径
    func downloadFilePath(_ url: String) -> URL? {
        if let path = downloadPlist[url] as? String,
            let pathUrl = URL(string: path) {
            return pathUrl
        }
        return nil
    }
    /// 下载百分比
    func downloadPercent(_ url: String) -> Double {
        let percent = progressPlist[url] as? Double ?? 0
        if percent == 1 && downloadPlist[url] == nil {
            return 0
        }
        return percent
    }
    /// 下载状态
    func downloadStatus(_ url: String) -> DownloadStatus {
        let task = downloadTasks[url]
        if downloadPercent(url) == 1 { return .complete }
        return task?.downloadStatus ?? .suspend
    }
    /// 下载进度
    @discardableResult
    func downloadProgress(_ url: String, progress: @escaping ((Double)->())) -> DownloadTaskManager? {
        if let task = downloadTasks[url], downloadPercent(url) < 1 {
            task.downloadProgress(progress: { pro in
                progress(pro)
            })
            return task
        } else {
            let pro = downloadPercent(url)
            progress(pro)
            return nil
        }
    }
}

// MARK: - 下载状态
public enum DownloadStatus {
    case downloading
    case suspend
    case complete
}

// MARK: - taskManager
public class DownloadTaskManager {
    fileprivate var downloadRequest: DownloadRequest?
    fileprivate var downloadStatus: DownloadStatus = .suspend
    fileprivate var cancelCompletion: (()->())?
    
    var url: String?
    @discardableResult
    fileprivate func download(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DownloadTaskManager
    {
        
        self.url = url
        let destination = downloadDestination()
        let resumeData = dataPlist[url] as? Data
        if let resumeData = resumeData {
            downloadRequest = Alamofire.download(resumingWith: resumeData, to: destination)
        } else {
            downloadRequest = Alamofire.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers, to: destination)
        }
        downloadStatus = .downloading
        return self
    }
    
    /// 下载进度
    @discardableResult
    public func downloadProgress(progress: @escaping ((Double) -> Void)) -> DownloadTaskManager {
        downloadRequest?.downloadProgress(closure: { (pro) in
            progressPlist[self.url!] = pro.fractionCompleted
            progressPlist.write(to: progressPath, atomically: true)
            progress(pro.fractionCompleted)
        })
        return self
    }
    /// 响应
    public func response(completion: @escaping (Alamofire.Result<String>)->()) {
        downloadRequest?.responseData(completionHandler: { (response) in
            switch response.result {
            case .success:
                self.downloadStatus = .complete
                let str = response.destinationURL?.absoluteString
                if self.cancelCompletion != nil { self.cancelCompletion!() }
                completion(Alamofire.Result.success(str!))
            case .failure(let error):
                self.downloadStatus = .suspend
                dataPlist[self.url!] = response.resumeData
                dataPlist.write(to: dataPath, atomically: true)
                if self.cancelCompletion != nil { self.cancelCompletion!() }
                completion(Alamofire.Result.failure(error))
            }
        })
    }
    /// 下载文件位置
    private func downloadDestination() -> DownloadRequest.DownloadFileDestination {
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let fileURL = cacheDirectory().appendingPathComponent("Download/\(response.suggestedFilename!)")
            downloadPlist[self.url!] = response.suggestedFilename!
            downloadPlist.write(to: downloadPath, atomically: true)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return destination
    }
}

// MARK: - filePath
fileprivate let dataPlist = dictionaryOfData("DaisyData.plist")
fileprivate let progressPlist = dictionaryOfData("DaisyProgress.plist")
fileprivate let downloadPlist = dictionaryOfData("downloadPath.plist")
fileprivate let progressPath = cacheDirectory().appendingPathComponent("DaisyProgress.plist")
fileprivate let dataPath = cacheDirectory().appendingPathComponent("DaisyData.plist")
fileprivate let downloadPath = cacheDirectory().appendingPathComponent("downloadPath.plist")

fileprivate func cacheDirectory() -> URL {
    let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    let fileURL = cachesURL.appendingPathComponent("Download")
    return fileURL
}
fileprivate func dictionaryOfData(_ fileName: String) -> NSMutableDictionary {
    let path = cacheDirectory()
    let filePath = path.appendingPathComponent(fileName)
    var dic: NSMutableDictionary?
    if let dict = NSMutableDictionary(contentsOf: filePath) {
        dic = dict
    } else {
        dic = NSMutableDictionary()
    }
    return dic!
}
