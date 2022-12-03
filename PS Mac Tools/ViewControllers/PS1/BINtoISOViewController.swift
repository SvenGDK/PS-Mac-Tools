//
//  BINtoISOViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa
import UniformTypeIdentifiers

class BINtoISOViewController: NSViewController {
    
    let bintype = UTType(tag: "bin", tagClass: .filenameExtension, conformingTo: .archive)!
    let cuetype = UTType(tag: "cue", tagClass: .filenameExtension, conformingTo: .data)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 760, height: 360)
    }
    
    
    @IBOutlet weak var inputBINFileTextField: NSTextField!
    @IBOutlet weak var inputCUEFileTextField: NSTextField!
    @IBOutlet weak var destinationFolderTextField: NSTextField!
    
    
    @IBAction func browseBINFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your PS3 ISO"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [bintype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            inputBINFileTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func browseCUEFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your PS3 ISO"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [cuetype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            inputCUEFileTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func browseDestinationFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Where do you want to save your .iso file?"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            destinationFolderTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func converToISO(_ sender: NSButton) {
        
        if inputBINFileTextField.stringValue != "" && inputCUEFileTextField.stringValue != "" && destinationFolderTextField.stringValue != "" {
            
            let destinationFileName = (inputBINFileTextField.stringValue as NSString).lastPathComponent.replacingOccurrences(of: ".bin", with: "")
            
            let alert = NSAlert()
            alert.messageText = "Please confirm"
            alert.informativeText = "Do you really want to convert " + destinationFileName + " ? .bin and .cue files will not be deleted."
            alert.addButton(withTitle: "Download")
            alert.addButton(withTitle: "Cancel")
            
            if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                let bchunk = Bundle.main.path(forResource: "bchunk", ofType: "")
                let task = Process()
                let outpipe = Pipe()
                
                task.launchPath = "/bin/sh"
                task.arguments = ["-c", "'" + bchunk! + "' -p " + "'" + inputBINFileTextField.stringValue + "' '" + inputCUEFileTextField.stringValue + "' '" + destinationFolderTextField.stringValue + "/" + destinationFileName + "'"]
 
                task.standardOutput = outpipe

                task.launch()
                
                let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(decoding: outdata, as: UTF8.self)
                
                task.waitUntilExit()
                
                print(output)
                
                let successAlert = NSAlert()
                successAlert.messageText = "ISO Created"
                successAlert.informativeText = "Open output folder?"
                successAlert.addButton(withTitle: "Open")
                successAlert.addButton(withTitle: "Close")
                
                if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                {
                    NSWorkspace.shared.open(URL(fileURLWithPath: destinationFolderTextField.stringValue))
                }
            }
            
        }
        
    }
    
    
    
}
