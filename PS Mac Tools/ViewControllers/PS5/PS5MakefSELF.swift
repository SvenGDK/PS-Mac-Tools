//
//  PS5MakefSELF.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 06/01/2024.
//

import Cocoa

class PS5MakefSELF: NSViewController, NSTextFieldDelegate {
    
    
    @IBOutlet weak var BackupFolderTextField: NSTextField!
    @IBOutlet weak var MakeButton: NSButton!
    @IBOutlet var MakeLogTextView: NSTextView!
   
    var Observer1 : NSObjectProtocol?
    var Observer2 : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackupFolderTextField.delegate = self
        MakeLogTextView.font = NSFont.systemFont(ofSize: 16)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if BackupFolderTextField.stringValue.isEmpty {
            MakeButton.isEnabled = false
        } else {
            MakeButton.isEnabled = true
        }
    }
    
    @IBAction func BrowseBackupFolder(_ sender: NSButton) {
        
        let FolderBrowserDialog = NSOpenPanel()

        FolderBrowserDialog.title = "Select your backup folder with dumped SELF files"
        FolderBrowserDialog.showsResizeIndicator = true
        FolderBrowserDialog.showsHiddenFiles = false
        FolderBrowserDialog.canChooseFiles = false
        FolderBrowserDialog.canChooseDirectories = true
        FolderBrowserDialog.allowsMultipleSelection = false

        if (FolderBrowserDialog.runModal() ==  NSApplication.ModalResponse.OK) {
            BackupFolderTextField.stringValue = FolderBrowserDialog.url!.path
            MakeButton.isEnabled = true
        }
        
    }
    
    @IBAction func StartMake(_ sender: NSButton) {
        MakeLogTextView.string = ""
        
        let BackupDirectory: String = BackupFolderTextField.stringValue
        if MakefSELF(BackupDir: BackupDirectory) == true {
            
            let MakeSuccessAlert = NSAlert()
            MakeSuccessAlert.messageText = "Done !"
            MakeSuccessAlert.informativeText = "All files have been fake signed."
            MakeSuccessAlert.addButton(withTitle: "Close")
    
            MakeSuccessAlert.runModal()
        }
    }
    
    func MakefSELF(BackupDir: String) -> Bool {
        
        var CollectedFiles: [URL] = []
        let SelectedDirAsURL = URL(string: BackupDir)!
        
        // Enumerate files and collect files to fake sign
        if let enumerator = FileManager.default.enumerator(at: SelectedDirAsURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        
                        switch fileURL.pathExtension {
                        case "prx", "sprx", "elf", "self", "bin":
                            CollectedFiles.append(fileURL)
                        default:
                            print("Other file.")
                        }
                    
                    }
                } catch { print(error, fileURL) }
            }
        }
        
        // Fake sign each collected file
        for CollectedFile in CollectedFiles {
            let FilePath: String = CollectedFile.path
            let FileDir: String = CollectedFile.deletingLastPathComponent().path
            let FileName: String = CollectedFile.lastPathComponent

            let makefself = Bundle.main.path(forResource: "make_fself", ofType: "")
            let makefselfTask = Process()
            makefselfTask.launchPath = "/bin/sh"
            makefselfTask.arguments = ["-c", "'" + makefself! + "' '" + FilePath + "' '" + FileDir + "/" + FileName + ".esback'"]

            let OutPipe = Pipe()
            makefselfTask.standardOutput = OutPipe
            let outHandle = OutPipe.fileHandleForReading
            outHandle.waitForDataInBackgroundAndNotify()
            
            Observer1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                               object: outHandle, queue: nil) {  notification -> Void in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        //Update MakeLogTextView
                        self.MakeLogTextView.string += str as String
                        self.MakeLogTextView.scrollToEndOfDocument(nil)
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                } else {
                    NotificationCenter.default.removeObserver(self.Observer1!)
                }
            }
            
            Observer2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                               object: makefselfTask, queue: nil) { notification -> Void in
                NotificationCenter.default.removeObserver(self.Observer2!)
            }
            
            makefselfTask.launch()
            makefselfTask.waitUntilExit()
        }
        
        return true
    }
    
}
