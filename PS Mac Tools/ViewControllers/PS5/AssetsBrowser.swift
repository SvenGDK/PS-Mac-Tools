//
//  AssetsBrowser.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/01/2024.
//

import Cocoa
import AVKit
import AVFoundation

class AssetsBrowser: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var FilesTableView: NSTableView!
    @IBOutlet weak var FilePlayer: AVPlayerView!
    @IBOutlet weak var FileViewer: NSImageView!
    
    public var AssetsFilePath: String?
    var AssetFiles: [AssetFile] = []
    
    var PlayerContextMenu = NSMenu()
    let ShowAssetsBrowserMenuItem = NSMenuItem(title: "Show files list", action: #selector(ShowAssetsBrowser(_:)), keyEquivalent: "")
    let PausePlayerMenuItem = NSMenuItem(title: "Pause playback", action: #selector(PausePlayer(_:)), keyEquivalent: "")
    let StopPlayerMenuItem = NSMenuItem(title: "Stop playback", action: #selector(StopPlayer(_:)), keyEquivalent: "")
    
    var IsMediaPlaying: Bool = false
    
    enum AssetType {
        case Video
        case Audio
        case Image
        case Font
    }
    
    struct AssetFile {
        var FilePath: String?
        var FileName: String?
        var FileType: AssetType?
        var FileIcon: NSImage?
    }
    
    func AddPlayerContextMenu() {
        PlayerContextMenu.addItem(ShowAssetsBrowserMenuItem)
        PlayerContextMenu.addItem(PausePlayerMenuItem)
        PlayerContextMenu.addItem(StopPlayerMenuItem)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FilesTableView.dataSource = self
        FilesTableView.delegate = self
        FilesTableView.doubleAction = #selector(FileDoubleClick)

        AddPlayerContextMenu()
        FilePlayer.menu = PlayerContextMenu
        
        LoadAssetFiles()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        FilesTableView.reloadData()
        AnimateFilesTableView(ShowTable: true)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return AssetFiles.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "FilesColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "FilesCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            cellView.textField?.stringValue = AssetFiles[row].FileName!
            
            switch AssetFiles[row].FileType! {
            case AssetType.Audio:
                cellView.imageView?.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)
            case AssetType.Video:
                cellView.imageView?.image = NSImage(systemSymbolName: "video", accessibilityDescription: nil)
            case AssetType.Image:
                cellView.imageView?.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
            case AssetType.Font:
                cellView.imageView?.image = NSImage(systemSymbolName: "NSFontPanel", accessibilityDescription: nil)
            }

            return cellView
        }
        else
        {
            return nil
        }
    }
    
    func LoadAssetFiles() {
        if AssetsFilePath != nil {
            
            let url = URL(fileURLWithPath: AssetsFilePath!)
            
            if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                
                for case let fileURL as URL in enumerator {
                    do {
                        let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                        if fileAttributes.isRegularFile! {
                            
                            var NewAssetFile: AssetFile = AssetFile(FilePath: fileURL.path, FileName: fileURL.lastPathComponent)
                            
                            switch fileURL.pathExtension {
                            case "png", "jpg", "jpeg":
                                NewAssetFile.FileType = AssetType.Image
                                NewAssetFile.FileIcon = nil
                                
                                AssetFiles.append(NewAssetFile)
                            case "mp4", "webm":
                                NewAssetFile.FileType = AssetType.Video
                                NewAssetFile.FileIcon = nil
                                
                                AssetFiles.append(NewAssetFile)
                            case "ogg":
                                NewAssetFile.FileType = AssetType.Audio
                                NewAssetFile.FileIcon = nil
                                
                                AssetFiles.append(NewAssetFile)
                            case "ttf":
                                NewAssetFile.FileType = AssetType.Font
                                NewAssetFile.FileIcon = nil
                                
                                AssetFiles.append(NewAssetFile)
                            default:
                                print("Unsupported file found.")
                            }
                        
                        }
                    } catch { print(error, fileURL) }
                }
            }
        }
    }
    
    @objc func FileDoubleClick() {
        let SelectedRow: Int = FilesTableView.selectedRow
        let SelectedItem: AssetFile = AssetFiles[SelectedRow]

        switch SelectedItem.FileType! {
            
        case AssetType.Audio, AssetType.Video:
            // Hide image if shown
            if FileViewer.image != nil {
                FileViewer.image = nil
            }
            
            // Play selected file
            let FileToPlay = SelectedItem.FilePath!
            FilePlayer.player = AVPlayer(url: URL(fileURLWithPath: FileToPlay))
            FilePlayer.player?.play()
            
            AnimateFilesTableView(ShowTable: false)
            IsMediaPlaying = true
            
        case AssetType.Image:
            // Stop playback if running
            if IsMediaPlaying {
                FilePlayer.player?.pause()
                FilePlayer.player = nil
                IsMediaPlaying = false
            }
            
            // Show image
            FileViewer.image = NSImage(byReferencingFile: SelectedItem.FilePath!)
            
        case AssetType.Font:
            // Stop playback if running
            if IsMediaPlaying {
                FilePlayer.player?.pause()
                FilePlayer.player = nil
                IsMediaPlaying = false
            }
            // Hide image if shown
            if FileViewer.image != nil {
                FileViewer.image = nil
            }
            

        }
        
    }
    
    func AnimateFilesTableView(ShowTable: Bool) {
        let animationDuration = 0.5
        var newWidth: CGFloat = 325
        
        if ShowTable == true {
            newWidth = 325
        } else {
            newWidth = 0
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            FilesTableView.enclosingScrollView?.frame.size.width = newWidth
        }, completionHandler: nil)
    }
    
    @objc private func ShowAssetsBrowser(_ sender: AnyObject) {
        // Bring back the files table
        AnimateFilesTableView(ShowTable: true)
    }
    
    @objc private func PausePlayer(_ sender: AnyObject) {
        if IsMediaPlaying {
            FilePlayer.player?.pause()
            PausePlayerMenuItem.title = "Resume playback"
            IsMediaPlaying = false
        } else {
            FilePlayer.player?.play()
            PausePlayerMenuItem.title = "Pause playback"
            IsMediaPlaying = true
        }
    }
    
    @objc private func StopPlayer(_ sender: AnyObject) {
        if IsMediaPlaying {
            FilePlayer.player?.pause()
            FilePlayer.player = nil
            FilePlayer = nil
            IsMediaPlaying = false
        }
    }
    
}
