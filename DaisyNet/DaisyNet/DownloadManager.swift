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
        let key = cacheKey(url, parameters)
        let taskManager = DownloadTaskManager()
        taskManager.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        downloadTasks[key] = taskManager
        taskManager.cancelCompletion = {
            self.downloadTasks.removeValue(forKey: url)
        }
        return taskManager
    }
    /// 暂停下载
    func cancel(_ url: String, parameters: Parameters?) {
        let key = cacheKey(url, parameters)
        let task = downloadTasks[key]
        task?.downloadRequest?.cancel()
        task?.cancelCompletion = {
            self.downloadTasks.removeValue(forKey: key)
        }
    }
    /// 删除单个下载
    func delete(_ url: String, parameters: Parameters?) {
        let key = cacheKey(url, parameters)
        let task = downloadTasks[key]
        task?.downloadStatus = .suspend
        task?.downloadRequest?.cancel()
        delete(task: task, key: key)
        task?.cancelCompletion = {
            self.delete(task: task, key: key)
        }
    }
    
    private func delete(task: DownloadTaskManager?, key: String) {
        if let path = downloadPlist[key] as? String {
            let fileURL = cacheDirectory().appendingPathComponent("Download/\(path)")
            do {
                try FileManager.default.removeItem(at: fileURL)
                DaisyLog("删除成功")
            } catch {
                DaisyLog("删除失败")
            }
        }
        downloadTasks.removeValue(forKey: key)
        dataPlist.removeObject(forKey: key)
        downloadPlist.removeObject(forKey: key)
        progressPlist.removeObject(forKey: key)
        dataPlist.write(to: dataPath, atomically: true)
        progressPlist.write(to: progressPath, atomically: true)
        downloadPlist.write(to: downloadPath, atomically: true)
    }
    /// 下载完成路径
    func downloadFilePath(_ url: String, parameters: Parameters?) -> URL? {
        let key = cacheKey(url, parameters)
        if let path = downloadPlist[key] as? String,
            let pathUrl = URL(string: path) {
            return pathUrl
        }
        return nil
    }
    /// 下载百分比
    func downloadPercent(_ url: String, parameters: Parameters?) -> Double {
        let key = cacheKey(url, parameters)
        let percent = progressPlist[key] as? Double ?? 0
        if percent == 1 && downloadPlist[key] == nil {
            return 0
        }
        return percent
    }
    /// 下载状态
    func downloadStatus(_ url: String, parameters: Parameters?) -> DownloadStatus {
        let key = cacheKey(url, parameters)
        let task = downloadTasks[key]
        if downloadPercent(url, parameters: parameters) == 1 { return .complete }
        return task?.downloadStatus ?? .suspend
    }
    /// 下载进度
    @discardableResult
    func downloadProgress(_ url: String, parameters: Parameters?, progress: @escaping ((Double)->())) -> DownloadTaskManager? {
        let key = cacheKey(url, parameters)
        if let task = downloadTasks[key], downloadPercent(url, parameters: parameters) < 1 {
            task.downloadProgress(progress: { pro in
                progress(pro)
            })
            return task
        } else {
            let pro = downloadPercent(url, parameters: parameters)
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
    
    private var key: String?
    @discardableResult
    fileprivate func download(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DownloadTaskManager
    {
        
        self.key = cacheKey(url, parameters)
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
            progressPlist[self.key!] = pro.fractionCompleted
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
                dataPlist[self.key!] = response.resumeData
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
            downloadPlist[self.key!] = response.suggestedFilename!
            downloadPlist.write(to: downloadPath, atomically: true)
//            CacheManager.default.setObject(response.suggestedFilename!, forKey: self.url!)
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
