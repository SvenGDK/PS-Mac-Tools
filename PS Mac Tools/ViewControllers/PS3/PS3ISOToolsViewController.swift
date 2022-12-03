//
//  PS3ISOToolsViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 15/05/2021.
//

import Cocoa
import UniformTypeIdentifiers

class PS3ISOToolsViewController: NSViewController {
    
    @IBOutlet weak var makeGameFolderTextField: NSTextField!
    @IBOutlet weak var makeOutputFolderTextField: NSTextField!
    @IBOutlet weak var makeBrowseOutputFolderButton: NSButton!
    @IBOutlet weak var makeButton: NSButton!
    @IBOutlet weak var makeCheckBox: NSButton!
    
    @IBOutlet weak var extractISOFileTextField: NSTextField!
    @IBOutlet weak var extractOutputFolderTextField: NSTextField!
    @IBOutlet weak var extractBrowseOutputFolderButton: NSButton!
    @IBOutlet weak var extractButton: NSButton!
    
    @IBOutlet weak var splitorMergeTextField: NSTextField!
    @IBOutlet weak var splitorMergeBrowseButton: NSButton!
    @IBOutlet weak var splitorMergeButton: NSButton!
    @IBOutlet weak var splitCheckBox: NSButton!
    
    @IBOutlet weak var patchTextField: NSTextField!
    @IBOutlet weak var patchBrowseButton: NSButton!
    @IBOutlet weak var patchComboBox: NSPopUpButton!
    @IBOutlet weak var patchButton: NSButton!
    
    let isotype = UTType(tag: "iso", tagClass: .filenameExtension, conformingTo: .diskImage)!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1000, height: 600)
    }
    
    @IBAction func browseMakeInputFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose your game folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            makeGameFolderTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func browseMakeOutputFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Where do you want to save your .iso file?"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            makeOutputFolderTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func changeDefaultMakeLocation(_ sender: NSButton) {
        if sender.state == .on {
            makeOutputFolderTextField.isEnabled = false
            makeBrowseOutputFolderButton.isEnabled = false
        }
        else
        {
            makeOutputFolderTextField.isEnabled = true
            makeBrowseOutputFolderButton.isEnabled = true
        }
    }
    
    @IBAction func browsePS3ISO(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your PS3 ISO"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [isotype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            extractISOFileTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func browseExtractOutputFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your output folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            extractOutputFolderTextField.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func changeDefaultExtractLocation(_ sender: NSButton) {
        if sender.state == .on {
            extractOutputFolderTextField.isEnabled = false
            extractBrowseOutputFolderButton.isEnabled = false
        }
        else
        {
            extractOutputFolderTextField.isEnabled = true
            extractBrowseOutputFolderButton.isEnabled = true
        }
    }
    
    @IBAction func browseSplitorMergeLocation(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your PS3 ISO or a game folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [isotype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            splitorMergeTextField.stringValue = result!.path
            splitorMergeButton.isEnabled = true
            
            if result!.path.contains(".iso") {
                splitorMergeButton.stringValue = "Split"
            }
            else
            {
                splitorMergeButton.stringValue = "Merge"
            }
            
        } else {
            return
        }
    }
    
    @IBAction func browsePatchFileLocation(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Select your PS3 ISO"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [isotype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            patchTextField.stringValue = result!.path
            patchButton.isEnabled = true
        } else {
            return
        }
    }
    
    @IBAction func makeSelectedISO(_ sender: NSButton) {
        makePS3ISO(gameFolder: makeGameFolderTextField.stringValue, outputFolder: makeOutputFolderTextField.stringValue)
    }
    
    
    func makePS3ISO(gameFolder: String, outputFolder: String) {
        
        let makeAlert = NSAlert()
        makeAlert.messageText = "Please confirm"
        makeAlert.informativeText = "Do you really want to create a PS3 ISO from: " + gameFolder + " ?"
        makeAlert.addButton(withTitle: "Yes")
        makeAlert.addButton(withTitle: "Cancel")
        
        if makeAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let makePS3ISO = Bundle.main.path(forResource: "makeps3iso", ofType: "")

            let task = Process()
            task.launchPath = "/bin/sh"
            
            if splitCheckBox.state == NSControl.StateValue.on {
                task.arguments = ["-c", "'" + makePS3ISO! + "' -s '" + gameFolder + "' '" + outputFolder + "'"]
            }
            else
            {
                task.arguments = ["-c", "'" + makePS3ISO! + "' '" + gameFolder + "' '" + outputFolder + "'"]
            }

            let outpipe = Pipe()
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
                NSWorkspace.shared.open(URL(fileURLWithPath: outputFolder))
            }
    
        }
        
    }
    
    @IBAction func extractSelectedISO(_ sender: NSButton) {
        extractFromISO(gameISO: extractISOFileTextField.stringValue, outputFolder: extractOutputFolderTextField.stringValue)
    }
    
    func extractFromISO(gameISO: String, outputFolder: String) {
        
        let extractAlert = NSAlert()
        extractAlert.messageText = "Please confirm"
        extractAlert.informativeText = "Do you really want to extract: " + gameISO + " ?"
        extractAlert.addButton(withTitle: "Yes")
        extractAlert.addButton(withTitle: "Cancel")
        
        if extractAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let extractPS3ISO = Bundle.main.path(forResource: "extractps3iso", ofType: "")

            let task = Process()
            task.launchPath = "/bin/sh"
            
            if splitCheckBox.state == NSControl.StateValue.on {
                task.arguments = ["-c", "'" + extractPS3ISO! + "' -s '" + gameISO + "' '" + outputFolder + "'"]
            }
            else
            {
                task.arguments = ["-c", "'" + extractPS3ISO! + "' '" + gameISO + "' '" + outputFolder + "'"]
            }

            let outpipe = Pipe()
            task.standardOutput = outpipe

            task.launch()

            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outdata, as: UTF8.self)

            task.waitUntilExit()
            
            print(output)
            
            let successAlert = NSAlert()
            successAlert.messageText = "ISO Extracted"
            successAlert.informativeText = "Open output folder?"
            successAlert.addButton(withTitle: "Open")
            successAlert.addButton(withTitle: "Close")
            
            if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                NSWorkspace.shared.open(URL(fileURLWithPath: outputFolder))
            }
    
        }
        
    }
    
    @IBAction func splitorMergeGame(_ sender: NSButton) {
        splitOrMergeSelectedGame(inputGame: splitorMergeTextField.stringValue, outputFolder: "")
    }
    
    func splitOrMergeSelectedGame(inputGame: String, outputFolder: String) {
        
        if splitorMergeTextField.stringValue.contains(".iso") {
            
            let splitAlert = NSAlert()
            splitAlert.messageText = "Please confirm"
            splitAlert.informativeText = "Do you really want to split: " + inputGame + " ?"
            splitAlert.addButton(withTitle: "Yes")
            splitAlert.addButton(withTitle: "Cancel")
            
            if splitAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                let splitPS3ISO = Bundle.main.path(forResource: "splitps3iso", ofType: "")

                let task = Process()
                task.launchPath = "/bin/sh"
                task.arguments = ["-c", "'" + splitPS3ISO! + "' '" + inputGame + "'"]

                let outpipe = Pipe()
                task.standardOutput = outpipe

                task.launch()

                let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(decoding: outdata, as: UTF8.self)

                task.waitUntilExit()
                
                print(output)
                
                let successAlert = NSAlert()
                successAlert.messageText = "ISO Splitted"
                successAlert.informativeText = "Open output folder?"
                successAlert.addButton(withTitle: "Open")
                successAlert.addButton(withTitle: "Close")
                
                if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                {
                    let gameFolder = URL(fileURLWithPath: inputGame).deletingLastPathComponent().path
                    NSWorkspace.shared.open(URL(fileURLWithPath: gameFolder))
                }
        
            }
            
        }
        else
        {
            
            let mergeAlert = NSAlert()
            mergeAlert.messageText = "Please confirm"
            mergeAlert.informativeText = "Do you really want to merge the files inside: " + inputGame + " ?"
            mergeAlert.addButton(withTitle: "Yes")
            mergeAlert.addButton(withTitle: "Cancel")
            
            if mergeAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                let task = Process()
                let gameDir = URL(fileURLWithPath: splitorMergeTextField.stringValue)
                var isoFiles = [String]()
                let keys = [URLResourceKey.isRegularFileKey, URLResourceKey.localizedNameKey]
                let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]
                var newGameISO: String = ""
                
                let enumerator = FileManager.default.enumerator(
                    at: gameDir,
                    includingPropertiesForKeys: keys,
                    options: options,
                    errorHandler: {(url, error) -> Bool in
                        return true
                })

                if enumerator != nil {
                    while let file = enumerator!.nextObject() {
                        let path = URL(fileURLWithPath: (file as! URL).path, relativeTo: gameDir).path
                        
                        if path.contains(".iso.") {
                            newGameISO = URL(fileURLWithPath: path).deletingPathExtension().path
                            isoFiles.append("'" + path + "'")
                        }
                        
                    }
                }
                
                let mergeString = isoFiles.joined(separator: " ")
                
                task.launchPath = "/bin/cat"
                task.arguments = [mergeString + " > '" + newGameISO + "'"]

                let outpipe = Pipe()
                task.standardOutput = outpipe

                task.launch()

                let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(decoding: outdata, as: UTF8.self)

                task.waitUntilExit()
                
                print(output)
                
                let successAlert = NSAlert()
                successAlert.messageText = "ISO Merged"
                successAlert.informativeText = "Open output folder?"
                successAlert.addButton(withTitle: "Open")
                successAlert.addButton(withTitle: "Close")
                
                if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                {
                    NSWorkspace.shared.open(URL(fileURLWithPath: inputGame))
                }

            }
            
        }
        
    }
    
    @IBAction func patchSelectedISO(_ sender: NSButton) {
        patchISO(gameISO: patchTextField.stringValue)
    }
    
    func patchISO(gameISO: String) {
        
        if patchTextField.stringValue.contains(".iso") {
            let patchAlert = NSAlert()
            patchAlert.messageText = "Please confirm"
            patchAlert.informativeText = "Do you really want to patch: " + gameISO + " with Firmware version " + patchComboBox.stringValue + "?"
            patchAlert.addButton(withTitle: "Yes")
            patchAlert.addButton(withTitle: "Cancel")
            
            if patchAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                let patchPS3ISO = Bundle.main.path(forResource: "patchps3iso", ofType: "")

                let task = Process()
                task.launchPath = "/bin/sh"
                task.arguments = ["-c", "'" + patchPS3ISO! + "' '" + gameISO + "' " + patchComboBox.stringValue]

                let outpipe = Pipe()
                task.standardOutput = outpipe

                task.launch()

                let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(decoding: outdata, as: UTF8.self)

                task.waitUntilExit()
                
                print(output)
                
                let successAlert = NSAlert()
                successAlert.messageText = "ISO Patched"
                successAlert.informativeText = "ISO " + gameISO + " patched with success!"
                successAlert.addButton(withTitle: "Close")
        
                successAlert.runModal()
        
            }
        }
        else
        {
            
        }
        
    }
    
}
