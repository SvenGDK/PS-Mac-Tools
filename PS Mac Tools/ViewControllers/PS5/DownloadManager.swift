//
//  DownloadManager.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 07/01/2024.
//

import Cocoa

class DownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    weak var delegate: DownloadManagerDelegate?
    var DLQueueItem: DownloadQueueItem?
    var DLQueueItemRowIndex: Int?
    var DownloadTasks: [URLSessionDownloadTask] = []
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let DownloadsDirectoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let DestinationURL = DownloadsDirectoryURL!.appendingPathComponent(self.DLQueueItem!.DownloadURL.lastPathComponent)
        let DataFromURL = NSData(contentsOf: location)
        DataFromURL?.write(to: DestinationURL, atomically: true)
    }

    func StartDownload(url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        DownloadTasks.append(task)
        task.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let DownloadProgressValue = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.delegate?.downloadProgressUpdated(Double(DownloadProgressValue * 100), self.DLQueueItemRowIndex!)
        }
    }

}

protocol DownloadManagerDelegate: AnyObject {
    func downloadProgressUpdated(_ progress: Double, _ rowIndex: Int)
}
