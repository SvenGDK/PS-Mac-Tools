//
//  FormatDriveViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 16/05/2021.
//

import Cocoa

class FormatDriveViewController: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate {
    
    @IBOutlet weak var driveComboBox: NSComboBox!
    
    var drives = [String]()
    var selectedDrive:String = ""
    var selectedDriveName:String = ""
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        loadDrives()
    }
    
    func loadDrives() {

        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "/usr/sbin/diskutil list external physical | grep -i /dev/disk"]

        let outpipe = Pipe()
        task.standardOutput = outpipe

        task.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outdata, as: UTF8.self).components(separatedBy: "\n")

        task.waitUntilExit()
        
        for drive in output
        {
            if drive != "" {
                let drivePath = drive.components(separatedBy: " ")[0]
                let driveName = getDriveName(cmd: "/bin/sh", args: "-c", "/usr/sbin/diskutil info " + drivePath + "s1 | grep \"Volume Name:\" | awk '{print $3}'")
                drives.append(drivePath + " - " + driveName.components(separatedBy: "\n")[0])
                driveComboBox.reloadData()
            }
        }
    }
    
    func getDriveName(cmd: String, args: String...) -> String {
        let task = Process()
        task.launchPath = cmd
        task.arguments = args

        let outpipe = Pipe()
        task.standardOutput = outpipe

        task.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outdata, as: UTF8.self)

        task.waitUntilExit()
        
        return output
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        drives.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        drives[index] as String
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        selectedDrive = drives[driveComboBox.indexOfSelectedItem].components(separatedBy: " - ")[0]
        selectedDriveName = drives[driveComboBox.indexOfSelectedItem].components(separatedBy: " - ")[1]
        
        print(selectedDrive)
        print(selectedDriveName)
    }
    
    @IBAction func formatSelectedDrive(_ sender: NSButton) {

        let alert = NSAlert()
        alert.messageText = "Format Drive"
        alert.informativeText = "You're about to format " + selectedDrive + " with the name " + selectedDriveName + "! \n Are you sure you want to format this drive ?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "Cancel")

        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            
            let formatScript = "do shell script \"sudo /usr/sbin/diskutil eraseDisk FAT32 " + selectedDriveName + " MBRFormat " + selectedDrive + "\" with administrator privileges"
            var formatError: NSDictionary?
            if let scriptObject = NSAppleScript(source: formatScript) {
                if let outputString = scriptObject.executeAndReturnError(&formatError).stringValue {
                    print("Success creating drive: " + outputString)
                    
                    let successAlert = NSAlert()
                    successAlert.messageText = "Success!"
                    successAlert.informativeText = "Complete Log: \n\n" + outputString
                    successAlert.addButton(withTitle: "Close")
                    successAlert.runModal()
                    
                } else if (formatError != nil) {
                    print("Error formating drive: ", formatError!)
                    
                    let errorAlert = NSAlert()
                    errorAlert.messageText = "Error creating drive!"
                    errorAlert.informativeText = "Complete Log: \n\n" +  formatError!.description
                    errorAlert.addButton(withTitle: "Close")
                    errorAlert.runModal()
                }
            }
            
        }
        
    }
    
    
}
