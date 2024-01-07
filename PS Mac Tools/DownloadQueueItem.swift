//
//  DownloadQueueItem.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 06/01/2024.
//

import Foundation

struct DownloadQueueItem {
    var GameID: String
    var FileName: String
    var FileSize: String
    var DownloadURL: URL
    var DownloadState: String
    var DownloadProgress: Double
    var MergeState: String
}
