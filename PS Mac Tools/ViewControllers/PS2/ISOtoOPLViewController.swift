//
//  ISOtoOPLViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa
import UniformTypeIdentifiers
import WebKit

class ISOtoOPLViewController: NSViewController, WKNavigationDelegate, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var webVi = WKWebView()
    let titleJS = "document.getElementById('table4').rows[0].cells[1].textContent"
    let isotype = UTType(tag: "iso", tagClass: .filenameExtension, conformingTo: .diskImage)!
    
    var drives = [String]()
    var selectedDrive:String = ""
    var selectedDriveName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDrives()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 505, height: 320)
    }

    @IBOutlet weak var inputISOFile: NSTextField!
    @IBOutlet weak var selectedGameTitle: NSTextField!
    @IBOutlet weak var selectedDriveList: NSComboBox!
    @IBOutlet weak var isDVDRadioButton: NSButton!
    @IBOutlet weak var isCDRadioButton: NSButton!
    
    func loadDrives() {

        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "ls /Volumes"]

        let outpipe = Pipe()
        task.standardOutput = outpipe

        task.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outdata, as: UTF8.self).components(separatedBy: "\n")

        task.waitUntilExit()
        
        for drive in output
        {
            if drive != "" {
                let drivePath = "/Volumes/" + drive
                let driveName = drive
                drives.append(drivePath + " - " + driveName.components(separatedBy: "\n")[0])
                selectedDriveList.reloadData()
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
    
    func runISOParser(fileInput: String) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let isoutil = Bundle.main.path(forResource: "isoinfo", ofType: "")
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "'" + isoutil! + "' -i '" + fileInput + "' -x '/SYSTEM.CNF;1'"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
            print(output)
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
            print(error)
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    
    func loadDatabaseContent(GameID: String) {
        let trimmedID = GameID.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullURL = URL(string: "https://psxdatacenter.com/psx2/games2/" + trimmedID + ".html")
        webVi.load(URLRequest(url: fullURL!))
    }
    
    func returnGameID(bootVar: String) -> String {
        return bootVar.components(separatedBy: ":\\")[1].replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: "_", with: "-", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: ";1", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    @IBAction func browseISOFile(_ sender: NSButton) {
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
            inputISOFile.stringValue = result!.path
        } else {
            return
        }
    }
    
    @IBAction func generateName(_ sender: NSButton) {
        let genereateNameAlert = NSAlert()
        genereateNameAlert.messageText = "Please choose"
        genereateNameAlert.informativeText = "What do you want to use as game title?"
        genereateNameAlert.addButton(withTitle: "Game ID")
        genereateNameAlert.addButton(withTitle: "Game Title")
        
        if genereateNameAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let ISOReaderOutput = runISOParser(fileInput: inputISOFile.stringValue).output
            
            var ISOGameID = ISOReaderOutput.filter({(item: String) -> Bool in
                let stringMatch = item.lowercased().range(of: "BOOT2 = ".lowercased())
                let stringMatch2 = item.lowercased().range(of: "BOOT2=".lowercased())
                if stringMatch == nil {
                    return stringMatch2 != nil ? true : false
                }
                else {
                    return stringMatch != nil ? true : false
                }
            })
            
            if ISOGameID.count == 0 {
                selectedGameTitle.stringValue = "Game ID not found"
            }
            else
            {
                if ISOGameID[0].starts(with: "BOOT2=") {
                    selectedGameTitle.stringValue = returnGameID(bootVar: ISOGameID[0].components(separatedBy: "=")[1])
                }
                else
                {
                    selectedGameTitle.stringValue = returnGameID(bootVar:ISOGameID[0].components(separatedBy: " = ")[1])
                }
            }
            
        }
        else
        {
            let ISOReaderOutput = runISOParser(fileInput: inputISOFile.stringValue).output
            var GameIDfromCNF: String = ""
            
            var ISOGameID = ISOReaderOutput.filter({(item: String) -> Bool in
                let stringMatch = item.lowercased().range(of: "BOOT2 = ".lowercased())
                let stringMatch2 = item.lowercased().range(of: "BOOT2=".lowercased())
                if stringMatch == nil {
                    return stringMatch2 != nil ? true : false
                }
                else {
                    return stringMatch != nil ? true : false
                }
            })
            
            if ISOGameID.count == 0 {
                selectedGameTitle.stringValue = "Game ID not found"
            }
            else
            {
                if ISOGameID[0].starts(with: "BOOT2=") {
                    GameIDfromCNF = returnGameID(bootVar:ISOGameID[0].components(separatedBy: "=")[1])
                    loadDatabaseContent(GameID: GameIDfromCNF)
                }
                else
                {
                    GameIDfromCNF = returnGameID(bootVar:ISOGameID[0].components(separatedBy: " = ")[1])
                    loadDatabaseContent(GameID: GameIDfromCNF)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webVi.evaluateJavaScript(titleJS) { (result, error) in
            if error == nil {
                let trimmedGameTitle = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                self.selectedGameTitle.stringValue = trimmedGameTitle
            }
            else {
                self.selectedGameTitle.stringValue = "Game Title not found."
            }
        }        
    }
    
    
    @IBAction func convertToOPL(_ sender: NSButton) {
        
        let alert = NSAlert()
        alert.messageText = "Please confirm"
        alert.informativeText = "Do you really want to convert " + selectedGameTitle.stringValue + " and copy to " + selectedDrive + " ? The .iso file not be deleted."
        alert.addButton(withTitle: "Convert")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let isotoOPL = Bundle.main.path(forResource: "iso2opl", ofType: "")
            let task = Process()
            let outpipe = Pipe()
            
            task.launchPath = "/bin/sh"
            
            if isCDRadioButton.state == NSControl.StateValue.on {
                task.arguments = ["-c", "'" + isotoOPL! + "' '" + inputISOFile.stringValue + "' '" + selectedDrive + "' '" + selectedGameTitle.stringValue + "' CD"]
            }
            else
            {
                task.arguments = ["-c", "'" + isotoOPL! + "' '" + inputISOFile.stringValue + "' '" + selectedDrive + "' '" + selectedGameTitle.stringValue + "' DVD"]
            }
            
            task.standardOutput = outpipe

            task.launch()
            
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outdata, as: UTF8.self)
            
            task.waitUntilExit()
            
            print(output)
            
            let successAlert = NSAlert()
            successAlert.messageText = "ISO installed on external drive"
            successAlert.informativeText = "Open folder?"
            successAlert.addButton(withTitle: "Open")
            successAlert.addButton(withTitle: "Close")
            
            if successAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                NSWorkspace.shared.open(URL(fileURLWithPath: selectedDrive))
            }
        }
        
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        drives.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        drives[index] as String
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        selectedDrive = drives[selectedDriveList.indexOfSelectedItem].components(separatedBy: " - ")[0]
        selectedDriveName = drives[selectedDriveList.indexOfSelectedItem].components(separatedBy: " - ")[1]
        
        print(selectedDrive)
        print(selectedDriveName)
    }
    
}
