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
    
    fileprivate var downloadTasks = [String: TaskManager]()
    
    @discardableResult
    func download(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> TaskManager
    {
        let taskManager = TaskManager()
        taskManager.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        downloadTasks[url] = taskManager
        return taskManager
    }
    
    func cancel(_ url: String) {
        let task = downloadTasks[url]
        task?.downloadRequest?.cancel()
        task?.cancelCompletion = {
            self.downloadTasks.removeValue(forKey: url)
        }
    }
    
    func delete(_ url: String) {
        let task = downloadTasks[url]
        task?.downloadStatus = .suspend
        task?.downloadRequest?.cancel()
        delete(task: task, url: url)
        task?.cancelCompletion = {
            self.delete(task: task, url: url)
        }
    }
    func delete(task: TaskManager?, url: String) {
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
    
    func downloadFilePath(_ url: String) -> URL? {
        if let path = downloadPlist[url] as? String,
            let pathUrl = URL(string: path) {
            return pathUrl
        }
        return nil
    }
    
    func downloadPercent(_ url: String) -> Double {
        let percent = progressPlist[url] as? Double ?? 0
        if percent == 1 && downloadPlist[url] == nil {
            return 0
        }
        return percent
    }
    
    func downloadStatus(_ url: String) -> DownloadStatus {
        let task = downloadTasks[url]
        if downloadPercent(url) == 1 { return .complete }
        return task?.downloadStatus ?? .suspend
    }
    
    @discardableResult
    func downloadProgress(_ url: String, progress: @escaping ((Double)->())) -> TaskManager? {
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

// MARK: - download Status
public enum DownloadStatus {
    case downloading
    case suspend
    case complete
}

// MARK: - taskManager
class TaskManager {
    var downloadRequest: DownloadRequest?
    var downloadStatus: DownloadStatus = .suspend
    var cancelCompletion: (()->())?
    
    var url: String?
    @discardableResult
    func download(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> TaskManager
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
    
    @discardableResult
    func downloadProgress(progress: @escaping ((Double) -> Void)) -> TaskManager {
        downloadRequest?.downloadProgress(closure: { (pro) in
            progressPlist[self.url!] = pro.fractionCompleted
            progressPlist.write(to: progressPath, atomically: true)
            progress(pro.fractionCompleted)
        })
        return self
    }
    
    func response(completion: @escaping (Alamofire.Result<String>)->()) {
        downloadRequest?.responseData(completionHandler: { (response) in
            switch response.result {
            case .success:
                self.downloadStatus = .complete
                let str = response.destinationURL?.absoluteString
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
    func downloadDestination() -> DownloadRequest.DownloadFileDestination {
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
let dataPlist = dictionaryOfData("DaisyData.plist")
let progressPlist = dictionaryOfData("DaisyProgress.plist")
let downloadPlist = dictionaryOfData("downloadPath.plist")
let progressPath = cacheDirectory().appendingPathComponent("DaisyProgress.plist")
let dataPath = cacheDirectory().appendingPathComponent("DaisyData.plist")
let downloadPath = cacheDirectory().appendingPathComponent("downloadPath.plist")

func cacheDirectory() -> URL {
    let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    let fileURL = cachesURL.appendingPathComponent("Download")
    return fileURL
}
func dictionaryOfData(_ fileName: String) -> NSMutableDictionary {
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
