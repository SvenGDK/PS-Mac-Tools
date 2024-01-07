//
//  CopyWindowViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 22/05/2021.
//

import Cocoa

class CopyWindowViewController: NSViewController, FileManagerDelegate {
    
    @IBOutlet weak var copyImage: NSImageView!
    @IBOutlet weak var copyMainText: NSTextField!
    @IBOutlet weak var copyProgressBar: NSProgressIndicator!
    @IBOutlet weak var copyDetailsText: NSTextField!
    @IBOutlet weak var browseButton: NSButton!
    @IBOutlet weak var destinationTextField: NSTextField!
    @IBOutlet weak var copyWaitingIndicator: NSProgressIndicator!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var muteCheckBox: NSButton!
    @IBOutlet weak var cancelCopyButton: NSButton!
    
    var sourceFolder: String = ""
    var sourceFolderContentCount: Int = 0
    var destFile: String = ""
    
    var dirsCopied: Int = 0
    var filesCopied: Int = 0
    var totalCopied: Int = 0
    
    var progressPercent: Double = 0
    var isBackupManagerMusicPlaying: Bool = false
    var backgroundAudioPlayerCopy: Process = Process()

    override func viewDidLoad() {
        super .viewDidLoad()
        
        browseButton.isEnabled = true
        destinationTextField.isEnabled = true
        cancelCopyButton.isEnabled = true

        prepareCopy()
        copyWaitingIndicator.startAnimation(self)
        
        if isBackupManagerMusicPlaying == true {
            muteCheckBox.state = NSControl.StateValue.off
        }
        else{
            muteCheckBox.state = NSControl.StateValue.on
            muteCheckBox.isEnabled = false
        }
    }
    
    func prepareCopy() {
        if !sourceFolder.contains(".iso") {
            if FileManager.default.fileExists(atPath: sourceFolder + "/PS3_GAME/ICON0.PNG") {
                copyImage.image = NSImage(byReferencingFile: sourceFolder + "/PS3_GAME/ICON0.PNG")
                print("Sucess getting: ICON0")
            }
            else {
                copyImage.image = nil
            }
            
            sourceFolderContentCount = try! FileManager.default.subpathsOfDirectory(atPath: sourceFolder).count
            copyProgressBar.maxValue = Double(sourceFolderContentCount)
            
            copyMainText.stringValue = "Preparing to copy " + URL.init(string: sourceFolder)!.lastPathComponent
            copyDetailsText.stringValue = "Waiting for destination folder ..."
        }
        else
        {
            let selectedGameISO = URL(fileURLWithPath: sourceFolder)
            let gameCacheFolder = selectedGameISO.deletingLastPathComponent().path + "/PSMT/"
            let selectedGameName = selectedGameISO.deletingPathExtension().lastPathComponent
            
            if FileManager.default.fileExists(atPath: gameCacheFolder + selectedGameName + "/PS3_GAME/ICON0.PNG") {
                copyImage.image = NSImage(byReferencingFile: gameCacheFolder + selectedGameName + "/PS3_GAME/ICON0.PNG")
                print("Sucess getting: ICON0")
            }
            else {
                copyImage.image = nil
            }
            
            sourceFolderContentCount = 1
            copyProgressBar.maxValue = 1
            
            copyMainText.stringValue = "Preparing to copy " + sourceFolder
            copyDetailsText.stringValue = "Waiting for destination folder ..."
        }
    }
    
    @IBAction func browseDestinationFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose your destination folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            destinationTextField.stringValue = result!.path
            
            copyDetailsText.stringValue = "Please confirm your selection to continue"
            copyButton.isEnabled = true
        }
    }
    
    @IBAction func startCopy(_ sender: NSButton) {
        
        browseButton.isEnabled = false
        destinationTextField.isEnabled = false
        copyButton.isEnabled = false
        cancelCopyButton.isEnabled = false
        
        if !sourceFolder.contains(".iso") {
            let gameName = URL.init(string: sourceFolder)?.lastPathComponent
            let destinationGameFolder = destinationTextField.stringValue + "/" + gameName!
            
            copyMainText.stringValue = "Copying..."
            copyToDestination(destinationFolder: destinationGameFolder)
        }
        else
        {
            let destinationFileName = URL(fileURLWithPath: sourceFolder).lastPathComponent
            let destinationFile = destinationTextField.stringValue + "/" + destinationFileName
            destFile = destinationFile
            
            copyMainText.stringValue = "Copying ISO to " + destFile
            
            newCopy()
        }
        
    }
    
    func copyToDestination(destinationFolder: String) {
        
        let gameFileManager = FileManager()
        let filesInGameFolder = gameFileManager.enumerator(atPath: sourceFolder)
        
        // Create GAME Directory
        if !FileManager.default.fileExists(atPath: destinationFolder) {
            
            try! FileManager.default.createDirectory(atPath: destinationFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Copy Content of GAME Directory
        while let fileOrFolder = filesInGameFolder?.nextObject() as? String {
            
            let destinationFile = fileOrFolder
            var isDir : ObjCBool = false
            
            DispatchQueue.global(qos: .background).async {
                
                if gameFileManager.fileExists(atPath: self.sourceFolder + "/" + destinationFile, isDirectory:&isDir) {
                    if isDir.boolValue {
                        try! FileManager.default.createDirectory(atPath: destinationFolder + "/" + destinationFile, withIntermediateDirectories: true, attributes: nil)
                    
                        self.dirsCopied += 1
                        self.totalCopied += 1
                    } else {
                        try! FileManager.default.copyItem(atPath: self.sourceFolder + "/" + destinationFile, toPath: destinationFolder + "/" + destinationFile)
      
                        self.filesCopied += 1
                        self.totalCopied += 1
                    }
                }

                DispatchQueue.main.async {
                    self.copyProgressBar.increment(by: 1)
                    self.copyDetailsText.stringValue = "Copied " + self.dirsCopied.description + " directories and " + self.filesCopied.description + " files."
                    
                    if self.copyProgressBar.doubleValue == Double(self.sourceFolderContentCount) {

                    }
                }
    
            }
    
        }
        
    }
    
    func newCopy() {
        
        DispatchQueue.global(qos: .userInteractive).async{
                do{
                    let bufferSize:Int = 64*1024;
                    var buffer = [Int32](repeating: 0, count: Int(bufferSize))
                    
                    let open_source = open(self.sourceFolder, O_RDONLY);
                    let open_target = open(self.destFile, O_RDWR | O_CREAT | O_TRUNC, S_IWUSR | S_IRUSR);
                    
                    let attrSource = try FileManager.default.attributesOfItem(atPath: self.sourceFolder)
                    
                    let sourceFileSize = attrSource[FileAttributeKey.size] as! UInt64
                    
                    var bytes_read = 0;
                    
                    bytes_read = read(open_source, &buffer, bufferSize);
                    
                    while(bytes_read > 0){
                        write(open_target, &buffer, bufferSize);
                        
                        if FileManager.default.fileExists(atPath: self.destFile) {
                            
                            let attrTarget = try FileManager.default.attributesOfItem(atPath: self.destFile)
                            let targetFileSize = attrTarget[FileAttributeKey.size] as! UInt64
                            let formattedStr = String(format: "%.0f", Double(targetFileSize)/Double(sourceFileSize) * 100)
                            
                            DispatchQueue.main.async {
                                self.copyProgressBar.doubleValue = self.progressPercent
                                self.copyDetailsText.stringValue = "Completed: " + formattedStr + " %"
                            }
                                
                            self.progressPercent = Double(targetFileSize)/Double(sourceFileSize)
                            print(self.progressPercent)

                        }
                        bytes_read = read(open_source, &buffer, bufferSize);
                    }
                    // copy is done, or an error occurred
                    close(open_source);
                    close(open_target);
                    sleep(2)
                    DispatchQueue.main.async {
                        
                        let alert = NSAlert()
                        alert.messageText = "Success!"
                        alert.informativeText = "ISO copied to: " + self.destFile
                        alert.addButton(withTitle: "Close")
                        
                        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                        {
                            self.dismiss(nil)
                        }
                        
                    }
                }
                catch{
                    print(error)
                }
                
            }
        
    }
    
    @IBAction func controlBackgroundPlayer(_ sender: NSButton) {
        backgroundAudioPlayerCopy.terminate()
        muteCheckBox.isEnabled = false
    }
    
    @IBAction func cancelCopy(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}
