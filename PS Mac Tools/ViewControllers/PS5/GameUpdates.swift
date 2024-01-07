//
//  GameUpdates.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/01/2024.
//

import Cocoa

class GameUpdates: NSViewController, NSTableViewDelegate, NSTableViewDataSource, DownloadManagerDelegate {
    
    @IBOutlet weak var DownloadQueueTableView: NSTableView!
    @IBOutlet weak var GameIDTextField: NSTextField!
    @IBOutlet weak var DownloadButton: NSButton!
    
    var DownloadQueueItems: [DownloadQueueItem] = []
    var SearchForGameID: String?
    var DownloadsContextMenu = NSMenu()
    var LibraryDelegate: PS5Library!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadQueueTableView.delegate = self
        DownloadQueueTableView.dataSource = self
        
        if SearchForGameID != nil {
            GameIDTextField.stringValue = SearchForGameID!
        }
        
        DownloadsContextMenu.addItem(NSMenuItem(title: "Merge selected patch from this source pkg", action: #selector(MergeSelectedItem(_:)), keyEquivalent: ""))
        DownloadQueueTableView.menu = DownloadsContextMenu
        LoadDownloads()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    @objc private func MergeSelectedItem(_ sender: AnyObject) {
        if !DownloadQueueTableView.selectedRowIndexes.isEmpty {
            let SelectedRow: Int = DownloadQueueTableView.selectedRow
            let MergePath: String = DownloadQueueItems[SelectedRow].DownloadURL.deletingLastPathComponent().path
            LibraryDelegate.MergeGamePatch(MergePath)
        }
    }
    
    func LoadDownloads() {
        
        let DownloadsDirectoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        var DownloadedPKGs: [URL] = []
        
        // Get pkg files from downloads folder
        if let enumerator = FileManager.default.enumerator(at: DownloadsDirectoryURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        
                        switch fileURL.pathExtension {
                        case "pkg":
                            DownloadedPKGs.append(fileURL)
                        default:
                            print("Other file.")
                        }
                    
                    }
                } catch { print(error, fileURL) }
            }
        }
        
        // Show downloaded pkgs in table
        for DownloadedPKG in DownloadedPKGs {
            let PKGFileName: String = DownloadedPKG.lastPathComponent
            let PKGGameID: String = PKGFileName.components(separatedBy: "-")[1].components(separatedBy: "_")[0]
            var PKGFileSize: String = ""
            do {
                if let sizeOnDisk = try DownloadedPKG.sizeOnDisk() {
                    PKGFileSize = sizeOnDisk
                }
            } catch {
                PKGFileSize = "0.0 GB on disk"
            }
            
            var PKGMergeState: String = ""
            let BaseName: String = DownloadedPKG.lastPathComponent.components(separatedBy: ".pkg")[0]
            if BaseName.hasSuffix("-merged") {
                PKGMergeState = "Merged"
            } else {
                PKGMergeState = "Not merged"
            }
            
            let NewDownloadQueueItem: DownloadQueueItem = DownloadQueueItem(GameID: PKGGameID, FileName: PKGFileName, FileSize: PKGFileSize, DownloadURL: DownloadedPKG, DownloadState: "Downloaded", DownloadProgress: 100, MergeState: PKGMergeState)
            AddQueueItem(QueueItem: NewDownloadQueueItem)
        }
                
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GamePatchesSelector" {
            let GamePatchesSelectorView = segue.destinationController as! GameUpdateSelector
            GamePatchesSelectorView.GameUpdatesDelegate = self
            GamePatchesSelectorView.CurrentGameID = ""
            
            if !GameIDTextField.stringValue.isEmpty {
                let ProsperoPatchesURL: URL = URL(string: "https://prosperopatches.com/" + GameIDTextField.stringValue)!
                GamePatchesSelectorView.ProsperoPatchesURL = ProsperoPatchesURL
                GamePatchesSelectorView.CurrentGameID = GameIDTextField.stringValue
            }
        }
        
    }
    
    func AddQueueItem(QueueItem: DownloadQueueItem) {
        DownloadQueueItems.append(QueueItem)
        DownloadQueueTableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DownloadQueueItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameIDColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "GameIDCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            cellView.textField?.stringValue = DownloadQueueItems[row].GameID

            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "FileNameColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "FileNameCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            cellView.textField?.stringValue = DownloadQueueItems[row].FileName

            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "PKGSizeColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PKGSizeCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            cellView.textField?.stringValue = DownloadQueueItems[row].FileSize

            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "DownloadStateColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "DownloadStateCellViewIdentifier")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? DownloadStateCellView else { return nil }
            
            cellView.DownloadStateTextField.stringValue = DownloadQueueItems[row].DownloadState
            cellView.DownloadStateProgressIndicator.doubleValue = DownloadQueueItems[row].DownloadProgress

            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "MergeStateColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "MergeStateCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            cellView.textField?.stringValue = DownloadQueueItems[row].MergeState

            return cellView
        }
        else
        {
            return nil
        }
    }
    
    @IBAction func DownloadSelection(_ sender: NSButton) {
        if !DownloadQueueTableView.selectedRowIndexes.isEmpty {
            if DownloadQueueTableView.numberOfSelectedRows > 1 {
                // Start download for each selected item
                let SelectedRows = DownloadQueueTableView.selectedRowIndexes
                SelectedRows.forEach { index in
                    let SelectedQueueItem: DownloadQueueItem = DownloadQueueItems[index]
                    let NewDownloadManager = DownloadManager()
                    NewDownloadManager.delegate = self
                    NewDownloadManager.DLQueueItem = SelectedQueueItem
                    NewDownloadManager.DLQueueItemRowIndex = index
                    NewDownloadManager.StartDownload(url: SelectedQueueItem.DownloadURL)
                }
            } else {
                let SelectedRow: Int = DownloadQueueTableView.selectedRow
                let SelectedQueueItem: DownloadQueueItem = DownloadQueueItems[SelectedRow]
                
                // Start download for selected item
                let NewDownloadManager = DownloadManager()
                NewDownloadManager.delegate = self
                NewDownloadManager.DLQueueItem = SelectedQueueItem
                NewDownloadManager.DLQueueItemRowIndex = SelectedRow
                NewDownloadManager.StartDownload(url: SelectedQueueItem.DownloadURL)
            }
        }
    }
    
    // Update the DownloadQueueItem & show new progress
    func downloadProgressUpdated(_ progress: Double, _ rowIndex: Int) {
        let NewNumberFormatter = NumberFormatter()
        NewNumberFormatter.numberStyle = .percent
        
        DownloadQueueItems[rowIndex].DownloadProgress = progress
        DownloadQueueItems[rowIndex].DownloadState = "Downloading " + NewNumberFormatter.string(from: NSNumber(value: progress / 100))!
        
        if progress == 100 {
            DownloadQueueItems[rowIndex].DownloadState = "Downloaded"
        }

        let QueueRowIndexSet = IndexSet(integer: rowIndex)
        let QueueColumnIndexSet = IndexSet(integer: 3)
        
        DispatchQueue.main.async {
            self.DownloadQueueTableView.reloadData(forRowIndexes: QueueRowIndexSet, columnIndexes: QueueColumnIndexSet)
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if !DownloadQueueTableView.selectedRowIndexes.isEmpty {
            DownloadButton.isEnabled = true
        } else {
            DownloadButton.isEnabled = false
        }
    }
    
}
