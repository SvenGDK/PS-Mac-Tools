//
//  ELFtoPBPViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa
import UniformTypeIdentifiers

class ELFtoPBPViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var SelectedELFTextField: NSTextField!
    @IBOutlet weak var SelectedAppTitleTextField: NSTextField!
    @IBOutlet weak var ProgressStatusTextField: NSTextField!
    @IBOutlet weak var ProgressBarIndicator: NSProgressIndicator!
    
    let ELFType = UTType(tag: "elf", tagClass: .filenameExtension, conformingTo: .data)!
    
    override func viewDidLoad() {
        super .viewDidLoad()
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 427, height: 300)
    }
    
    @IBAction func BrowseELFFile(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose your ELF file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [ELFType]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            SelectedELFTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func ConvertELF(_ sender: NSButton) {
        
        let makeAlert = NSAlert()
        let ELFFile = SelectedELFTextField.stringValue
        let outputDirectory = FileManager.default.currentDirectoryPath
 
        makeAlert.messageText = "Please confirm"
        makeAlert.informativeText = "Do you really want to convert the selected ELF file ?"
        makeAlert.addButton(withTitle: "Yes")
        makeAlert.addButton(withTitle: "Cancel")
        
        if makeAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            DispatchQueue.global().async {
                let ELFtoPBP = Bundle.main.path(forResource: "elf2pbp", ofType: "")
                let task = Process()
                let outpipe = Pipe()
                
                task.standardOutput = outpipe
                task.launchPath = "/bin/sh"
                task.arguments = ["-c", "'" + ELFtoPBP! + "' '" + ELFFile + "'"]
                task.standardOutput = outpipe
                
                DispatchQueue.main.async {
                    self.ProgressStatusTextField.isHidden = false
                    self.ProgressBarIndicator.isHidden = false
                    self.ProgressBarIndicator.startAnimation(self)
                }
                
                task.launch()
                task.waitUntilExit()
                
                DispatchQueue.main.async {
                    self.ProgressBarIndicator.isHidden = true
                    self.ProgressStatusTextField.isHidden = true
                    self.ProgressBarIndicator.stopAnimation(self)
                    
                    let successAlert = NSAlert()
                    successAlert.messageText = "PBP Created"
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
