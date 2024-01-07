//
//  PKGMerger.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 14/12/2023.
//

import Cocoa
import UniformTypeIdentifiers

class PKGMerger: NSViewController {
    
    @IBOutlet weak var SelectedDirectoryTectField: NSTextField!
    @IBOutlet weak var StartMergeButton: NSButton!
    @IBOutlet var MergeLogTextView: NSTextView!
    
    var MergeDownloadPath: String?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        MergeLogTextView.font = NSFont.systemFont(ofSize: 16)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
        
        if MergeDownloadPath != nil {
            SelectedDirectoryTectField.stringValue = MergeDownloadPath!
        }
    }
    
    var Observer1 : NSObjectProtocol?
    var Observer2 : NSObjectProtocol?
    
    @IBAction func BrowseMergeDirectory(_ sender: NSButton) {
        let FolderBrowserDialog = NSOpenPanel()

        FolderBrowserDialog.title = "Select your backup folder"
        FolderBrowserDialog.showsResizeIndicator = true
        FolderBrowserDialog.showsHiddenFiles = false
        FolderBrowserDialog.canChooseFiles = false
        FolderBrowserDialog.canChooseDirectories = true
        FolderBrowserDialog.allowsMultipleSelection = false

        if (FolderBrowserDialog.runModal() ==  NSApplication.ModalResponse.OK) {
            SelectedDirectoryTectField.stringValue = FolderBrowserDialog.url!.path
            StartMergeButton.isEnabled = true
        }
    }
    
    @IBAction func StartMerge(_ sender: NSButton) {
        MergeLogTextView.string = ""
        
        let MergeDirectory: String = SelectedDirectoryTectField.stringValue
        if MergePKG(MergeDir: MergeDirectory) == true {
            
            let MergeSuccessAlert = NSAlert()
            MergeSuccessAlert.messageText = "PKG Merged !"
            MergeSuccessAlert.informativeText = "PKG files have been merged"
            MergeSuccessAlert.addButton(withTitle: "Close")
    
            MergeSuccessAlert.runModal()
        }
    }
    
    func MergePKG(MergeDir: String) -> Bool {
        let pkgmerge = Bundle.main.path(forResource: "pkg_merge", ofType: "")
        let pkgmergeTask = Process()
        pkgmergeTask.launchPath = "/bin/sh"
        pkgmergeTask.arguments = ["-c", "'" + pkgmerge! + "' '" + MergeDir + "'"]
        
        let OutPipe = Pipe()
        pkgmergeTask.standardOutput = OutPipe
        let outHandle = OutPipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        Observer1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                           object: outHandle, queue: nil) {  notification -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    
                    //Update MergeLogTextView
                    if str.contains("beginning") {
                        self.MergeLogTextView.string += str as String
                        self.MergeLogTextView.scrollToEndOfDocument(nil)
                    }
                    else if str.contains("25%") {
                        self.MergeLogTextView.string += str as String
                        self.MergeLogTextView.scrollToEndOfDocument(nil)
                    }
                    else if str.contains("50%") {
                        self.MergeLogTextView.string += str as String
                        self.MergeLogTextView.scrollToEndOfDocument(nil)
                    }
                    else if str.contains("75%") {
                        self.MergeLogTextView.string += str as String
                        self.MergeLogTextView.scrollToEndOfDocument(nil)
                    }
                    else if str.contains("100%") {
                        self.MergeLogTextView.string += str as String
                        self.MergeLogTextView.scrollToEndOfDocument(nil)
                    }
                    else if str.contains("[success]") {
                        self.MergeLogTextView.string += str as String
                        self.MergeLogTextView.scrollToEndOfDocument(nil)
                    }
               
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(self.Observer1!)
            }
        }
        
        Observer2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                           object: pkgmergeTask, queue: nil) { notification -> Void in
            NotificationCenter.default.removeObserver(self.Observer2!)
        }
        
        pkgmergeTask.launch()
        pkgmergeTask.waitUntilExit()
        
        return true
    }
    
}
