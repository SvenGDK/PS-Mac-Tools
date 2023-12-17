//
//  BDBurner.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 04/12/2023.
//

import Cocoa
import UniformTypeIdentifiers

class BDBurner: NSViewController {
    
    @IBOutlet weak var AvailableDiscDrivesComboBox: NSComboBox!
    @IBOutlet weak var SelectedISOTextField: NSTextField!
    @IBOutlet weak var BurnStatusTextField: NSTextField!
    @IBOutlet weak var BurnProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var BurnButton: NSButton!
    @IBOutlet var BurnLogTextView: NSTextView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        BurnLogTextView.font = NSFont.systemFont(ofSize: 16)
        GetDiscDrives()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    struct DiscDrive {
        var DiscDriveName: String
        var DiscDrivePath: String
    }
    
    var DiscDrives = [DiscDrive]()
    var SelectedDiscDrive: DiscDrive!
    var SelectedISOFile: String = ""
    
    var Observer1 : NSObjectProtocol?
    var Observer2 : NSObjectProtocol?
    
    func GetDiscDrives() {
        let ListDrivesTask = Process()
        
        ListDrivesTask.launchPath = "/bin/sh"
        ListDrivesTask.arguments = ["-c", "hdiutil burn -list"]

        var output = [String]()
        let outpipe = Pipe()
        ListDrivesTask.standardOutput = outpipe

        ListDrivesTask.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        ListDrivesTask.waitUntilExit()
    
        if !output.isEmpty {
            if output.indices.contains(0) && output.indices.contains(1)  {
                let DiscDrive1 = DiscDrive(DiscDriveName: output[0], DiscDrivePath: output[1].trimmingCharacters(in: .whitespaces))
                DiscDrives.append(DiscDrive1)
            }
            
            if output.indices.contains(2) && output.indices.contains(3)  {
                let DiscDrive2 = DiscDrive(DiscDriveName: output[2], DiscDrivePath: output[3].trimmingCharacters(in: .whitespaces))
                DiscDrives.append(DiscDrive2)
            }
        }
        
        for AvailableDrive in DiscDrives {
            AvailableDiscDrivesComboBox.addItem(withObjectValue: AvailableDrive.DiscDriveName)
        }
    }
    
    @IBAction func RefreshDrivesList(_ sender: NSButton) {
        AvailableDiscDrivesComboBox.stringValue = ""
        AvailableDiscDrivesComboBox.removeAllItems()
        DiscDrives.removeAll()
        GetDiscDrives()
    }
    
    @IBAction func BrowseISOFile(_ sender: NSButton) {
        
        let OpenFileDialog = NSOpenPanel()

        OpenFileDialog.title = "Choose your .iso file"
        OpenFileDialog.showsResizeIndicator = true
        OpenFileDialog.showsHiddenFiles = false
        OpenFileDialog.canChooseFiles = true
        OpenFileDialog.canChooseDirectories = false
        OpenFileDialog.allowsMultipleSelection = false
        OpenFileDialog.allowedContentTypes = [UTType.diskImage]
        
        if (OpenFileDialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = OpenFileDialog.url
            SelectedISOFile = result!.path
            SelectedISOTextField.stringValue = result!.path
            BurnButton.isEnabled = true
        }
        
    }
    
    @IBAction func BurnDisc(_ sender: NSButton) {
        
        self.BurnProgressIndicator.startAnimation(self)
        
        let SelectedISO: String = SelectedISOTextField.stringValue
        let SelectedDiscDrivePath: String = DiscDrives[AvailableDiscDrivesComboBox.indexOfSelectedItem].DiscDrivePath
        let Args:String = "hdiutil burn '" + SelectedISO + "' -device '" + SelectedDiscDrivePath + "'"
        let hdiutilBurnTask = Process()
        
        hdiutilBurnTask.launchPath = "/bin/sh"
        hdiutilBurnTask.arguments = ["-c", Args]
        
        let OutPipe = Pipe()
        hdiutilBurnTask.standardOutput = OutPipe
        let outHandle = OutPipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        Observer1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                           object: outHandle, queue: nil) {  notification -> Void in
            
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    //Update BurnLogTextView
                    self.BurnLogTextView.string += str as String
                    self.BurnLogTextView.scrollToEndOfDocument(nil)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                self.BurnProgressIndicator.stopAnimation(self)
                NotificationCenter.default.removeObserver(self.Observer1!)
            }
            
        }
        
        Observer2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                           object: hdiutilBurnTask, queue: nil) { notification -> Void in
            self.BurnProgressIndicator.stopAnimation(self)
            NotificationCenter.default.removeObserver(self.Observer2!)
        }
        
        hdiutilBurnTask.launch()
        hdiutilBurnTask.waitUntilExit()
        
    }
    
}

