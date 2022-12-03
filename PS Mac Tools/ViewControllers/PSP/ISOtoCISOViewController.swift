//
//  ISOtoCISOViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa
import UniformTypeIdentifiers

class ISOtoCISOViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    @IBOutlet weak var SelectedISOTextField: NSTextField!
    @IBOutlet weak var SelectedOutputFolderTextField: NSTextField!
    @IBOutlet weak var SelectedCompressionLevelComboBox: NSComboBox!
    @IBOutlet weak var ConvertProgressBar: NSProgressIndicator!
    @IBOutlet weak var ConvertStatusTextField: NSTextField!
    
    let isotype = UTType(tag: "iso", tagClass: .filenameExtension, conformingTo: .diskImage)!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        for CompressionLevel in 1...9 {
            SelectedCompressionLevelComboBox.addItem(withObjectValue: CompressionLevel)
        }
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 427, height: 373)
    }
    
    @IBAction func BrowseISOFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose your PSP ISO file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [isotype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            SelectedISOTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func BrowseOutputFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your output folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            SelectedOutputFolderTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func ConvertISO(_ sender: NSButton) {
        
        let makeAlert = NSAlert()
        let gameISO = SelectedISOTextField.stringValue
        let outputDirectory = SelectedOutputFolderTextField.stringValue
        let compressionLevel = SelectedCompressionLevelComboBox.stringValue
        
        let fileURL = URL(string: gameISO)
        let outputFile = (fileURL?.deletingPathExtension().lastPathComponent.description)! + ".cso"

        makeAlert.messageText = "Please confirm"
        makeAlert.informativeText = "Do you really want to convert the selected iso file: ?"
        makeAlert.addButton(withTitle: "Yes")
        makeAlert.addButton(withTitle: "Cancel")
        
        if makeAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            DispatchQueue.global().async {
                let cISO = Bundle.main.path(forResource: "ciso", ofType: "")
                let task = Process()
                let outpipe = Pipe()
                
                task.launchPath = "/bin/sh"
                task.arguments = ["-c", "'" + cISO! + "' " + compressionLevel + " '" + gameISO + "' '" + outputDirectory + "/" + outputFile + "'"]
                task.standardOutput = outpipe
                
                var bigOutputString: String = ""
                
                outpipe.fileHandleForReading.readabilityHandler = { (fileHandle) -> Void in
                               let availableData = fileHandle.availableData
                               let newOutput = String.init(data: availableData, encoding: .utf8)
                               bigOutputString.append(newOutput!)
                               print("\(newOutput!)")
                           }
                
                DispatchQueue.main.async {
                    self.ConvertProgressBar.isHidden = false
                    self.ConvertStatusTextField.isHidden = false
                    self.ConvertProgressBar.startAnimation(self)
                }
                
                task.launch()
                task.waitUntilExit()
                
                DispatchQueue.main.async {
                    self.ConvertProgressBar.isHidden = true
                    self.ConvertStatusTextField.isHidden = true
                    self.ConvertProgressBar.stopAnimation(self)
                    
                    let successAlert = NSAlert()
                    successAlert.messageText = "CSO Created"
                    successAlert.informativeText = "Open output folder?"
                    successAlert.addButton(withTitle: "Open")
                    successAlert.addButton(withTitle: "Close")
                    
                    if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                    {
                        NSWorkspace.shared.open(URL(fileURLWithPath: outputDirectory))
                    }
                }
            }
    
        }
        
    }
    
    
}
