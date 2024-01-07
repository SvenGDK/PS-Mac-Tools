//
//  PS5CopyViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 07/01/2024.
//

import Cocoa

class PS5CopyViewController: NSViewController, FileManagerDelegate {
    
    @IBOutlet weak var CopyImageView: NSImageView!
    @IBOutlet weak var CopyDestinationPathTextField: NSTextField!
    @IBOutlet weak var BrowseButton: NSButton!
    @IBOutlet weak var StartCopyButton: NSButton!
    @IBOutlet weak var CurrentCopyStateTextField: NSTextField!
    @IBOutlet weak var CopyProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var CopyStateTextField: NSTextField!
    @IBOutlet weak var ClosePopoverButton: NSButton!
    @IBOutlet weak var CancelButton: NSButton!
    
    var SourceFolder: String = ""
    var SourceFolderItemsCount: Int = 0
    
    var DirectoriesCopied: Int = 0
    var FilesCopied: Int = 0
    var TotalCopied: Int = 0
    var ProgressPercent: Double = 0
    
    @IBAction func ClosePopover(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    @IBAction func BrowseDestinationFolder(_ sender: NSButton) {
        let FolderBrowserDialog = NSOpenPanel()

        FolderBrowserDialog.title = "Choose your destination folder"
        FolderBrowserDialog.showsResizeIndicator = true
        FolderBrowserDialog.showsHiddenFiles = false
        FolderBrowserDialog.canChooseFiles = false
        FolderBrowserDialog.canChooseDirectories = true
        FolderBrowserDialog.allowsMultipleSelection = false

        if (FolderBrowserDialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = FolderBrowserDialog.url
            
            CopyDestinationPathTextField.stringValue = result!.path
            StartCopyButton.isEnabled = true
        }
        
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        PrepareForCopy()
    }
    
    func PrepareForCopy() {
        if FileManager.default.fileExists(atPath: SourceFolder + "/sce_sys/icon0.png") {
            CopyImageView.image = NSImage(byReferencingFile: SourceFolder + "/sce_sys/icon0.png")
        }
        else {
            CopyImageView.image = nil
        }
        
        SourceFolderItemsCount = try! FileManager.default.subpathsOfDirectory(atPath: SourceFolder).count
        CopyProgressIndicator.maxValue = Double(SourceFolderItemsCount)
        
        CurrentCopyStateTextField.stringValue = "Preparing to copy " + URL.init(string: SourceFolder)!.lastPathComponent
        CopyStateTextField.stringValue = "Waiting for destination folder ..."
    }
    
    func CopyToNewDestination(DestinationFolder: String) {
        
        let CopyFileManager = FileManager()
        let FilesInGameFolder = CopyFileManager.enumerator(atPath: SourceFolder)
        
        // Create GAME Directory
        if !FileManager.default.fileExists(atPath: DestinationFolder) {
            
            try! FileManager.default.createDirectory(atPath: DestinationFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Copy Content of GAME Directory
        while let FileOrFolder = FilesInGameFolder?.nextObject() as? String {
            
            let DestinationFile = FileOrFolder
            var IsDir : ObjCBool = false
            
            DispatchQueue.global(qos: .background).async {
                
                if CopyFileManager.fileExists(atPath: self.SourceFolder + "/" + DestinationFile, isDirectory:&IsDir) {
                    if IsDir.boolValue {
                        try! FileManager.default.createDirectory(atPath: DestinationFolder + "/" + DestinationFile, withIntermediateDirectories: true, attributes: nil)
                    
                        self.DirectoriesCopied += 1
                        self.TotalCopied += 1
                    } else {
                        try! FileManager.default.copyItem(atPath: self.SourceFolder + "/" + DestinationFile, toPath: DestinationFolder + "/" + DestinationFile)
      
                        self.FilesCopied += 1
                        self.TotalCopied += 1
                    }
                }
                DispatchQueue.main.async {
                    self.CopyProgressIndicator.increment(by: 1)
                    self.CopyStateTextField.stringValue = "Copied " + self.DirectoriesCopied.description + " directories and " + self.FilesCopied.description + " files."
                    
                    if self.CopyProgressIndicator.doubleValue == Double(self.SourceFolderItemsCount) {
                        let CopyFinishedAlert = NSAlert()
                        CopyFinishedAlert.messageText = "Copy finished !"
                        CopyFinishedAlert.addButton(withTitle: "Close")
                        
                        // Show the alert inside the popover view
                        CopyFinishedAlert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                                self.view.window?.close()
                            }
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func StartCopy(_ sender: NSButton) {
        BrowseButton.isEnabled = false
        CopyDestinationPathTextField.isEnabled = false
        StartCopyButton.isEnabled = false
        ClosePopoverButton.isEnabled = false
        CancelButton.isEnabled = true
        
        let GameFolderName = URL(string: SourceFolder)?.lastPathComponent
        let DestinationGameFolder = CopyDestinationPathTextField.stringValue + "/" + GameFolderName!
        
        CurrentCopyStateTextField.stringValue = "Copy started ..."
        CopyToNewDestination(DestinationFolder: DestinationGameFolder)
    }
    
    @IBAction func CancelCopy(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}
