//
//  FTPGrabber.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 04/12/2023.
//

import Cocoa

class FTPGrabber: NSViewController, NSComboBoxDelegate {
    
    @IBOutlet weak var PS5IPAddressTextField: NSTextField!
    @IBOutlet weak var PS5PortTextField: NSTextField!
    @IBOutlet weak var SelectedDirectoryToGrabComboBox: NSComboBox!
    @IBOutlet weak var CreateFullDumpRadioButton: NSButton!
    @IBOutlet weak var MetadataOnlyRadioButton: NSButton!
    @IBOutlet weak var SELFOnlyRadioButton: NSButton!
    @IBOutlet weak var TransferStatusTextField: NSTextField!
    @IBOutlet weak var TransferProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var SelectedDownloadFolderTextField: NSTextField!
    @IBOutlet weak var StartButton: NSButton!
    @IBOutlet var LogTextView: NSTextView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        SelectedDirectoryToGrabComboBox.delegate = self
        LogTextView.font = NSFont.systemFont(ofSize: 16)
        for Directory in ComboBoxDirectories {
            SelectedDirectoryToGrabComboBox.addItem(withObjectValue: Directory)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    let ComboBoxDirectories:[String] = ["/mnt/sandbox/pfsmnt/", "/mnt/disc/"]
    var Observer1 : NSObjectProtocol?
    var Observer2 : NSObjectProtocol?
    
    @IBAction func BrowseDownloadFolder(_ sender: NSButton) {
        
        let OpenFileDialog = NSOpenPanel()
        
        OpenFileDialog.title = "Choose a save path"
        OpenFileDialog.showsResizeIndicator = true
        OpenFileDialog.showsHiddenFiles = false
        OpenFileDialog.canChooseFiles = false
        OpenFileDialog.canChooseDirectories = true
        OpenFileDialog.allowsMultipleSelection = false
        
        if (OpenFileDialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = OpenFileDialog.url
            SelectedDownloadFolderTextField.stringValue = result!.path
        }
        
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        
        if notification.object is NSComboBox {
            let SelectedIndex = SelectedDirectoryToGrabComboBox.indexOfSelectedItem
            
            switch ComboBoxDirectories[SelectedIndex] {
            case "/mnt/sandbox/pfsmnt/":
                CreateFullDumpRadioButton.isEnabled = true
                MetadataOnlyRadioButton.isEnabled = true
                SELFOnlyRadioButton.isEnabled = true
                StartButton.isEnabled = true
            case "/mnt/disc/":
                CreateFullDumpRadioButton.isEnabled = false
                MetadataOnlyRadioButton.isEnabled = false
                SELFOnlyRadioButton.isEnabled = false
                StartButton.isEnabled = true
            default:
                CreateFullDumpRadioButton.isEnabled = false
                MetadataOnlyRadioButton.isEnabled = false
                SELFOnlyRadioButton.isEnabled = false
                StartButton.isEnabled = false
            }
        }
        
    }
    
    func FindGameFolder() -> String {
        
        let cURLTask = Process()
        let Args:String = "curl ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + SelectedDirectoryToGrabComboBox.stringValue
        var GameFolder: String = ""
        
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        
        var output = [String]()
        let outpipe = Pipe()
        cURLTask.standardOutput = outpipe
        
        cURLTask.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        if !output.isEmpty {
            for Line in output {
                if Line.hasSuffix("app0") {
                    print("Found game folder: " + Line)
                    GameFolder = Line
                }
                else {
                    print("Other folder: " + Line)
                }
            }
        }
        
        // Return the app0 folder if exists
        if !GameFolder.isEmpty {
            if GameFolder.components(separatedBy: " ").indices.contains(8) {
                return GameFolder.components(separatedBy: " ")[8]
            }
            else {
                return ""
            }
        }
        else {
            return ""
        }
        
    }
    
    func DumpApp0(App0FolderName: String) -> Bool {
        
        self.TransferProgressIndicator.startAnimation(self)
        
        let FTPAddress: String = "ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + self.SelectedDirectoryToGrabComboBox.stringValue + App0FolderName + "/"
        let SavePath: String = SelectedDownloadFolderTextField.stringValue
        
        let wgetTask = Process()
        wgetTask.launchPath = "/opt/homebrew/bin/wget"
        wgetTask.arguments = ["-m",
                              "-nH",
                              "--cut-dirs=3",
                              "-np",
                              "-P",
                              SavePath,
                              FTPAddress]
        
        let OutPipe = Pipe()
        wgetTask.standardError = OutPipe
        let outHandle = OutPipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        Observer1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                           object: outHandle, queue: nil) {  notification -> Void in
            let data = outHandle.availableData
            
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    //Update LogTextView
                    self.LogTextView.string += str as String
                    self.LogTextView.scrollToEndOfDocument(nil)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                print("Dump finished.")
                self.TransferProgressIndicator.stopAnimation(self)
                NotificationCenter.default.removeObserver(self.Observer1!)
            }
            
        }
        
        Observer2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                           object: wgetTask, queue: nil) { notification -> Void in
            print("Process terminated.")
            self.TransferProgressIndicator.stopAnimation(self)
            NotificationCenter.default.removeObserver(self.Observer2!)
        }
        
        wgetTask.launch()
        wgetTask.waitUntilExit()
        
        return true
    }
    
    func CheckMetadata(App0FolderName: String) -> [String] {
        
        let GameID: String = App0FolderName.components(separatedBy: "-")[0]
        var UserAppMetaFolder: String = "/user/appmeta/"
        var SystemDataAppMetaFolder: String = "/system_data/priv/appmeta/"
        var NPBindFile: String = "/system_data/priv/appmeta/" + GameID + "/trophy2/"
        
        var cURLTask = Process()
        var Args:String = "curl ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + UserAppMetaFolder
        
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        
        var output = [String]()
        var outpipe = Pipe()
        cURLTask.standardOutput = outpipe
        
        LogTextView.string += "Checking " + UserAppMetaFolder + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        cURLTask.launch()
        
        var outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        if !output.isEmpty {
            for Line in output {
                if Line.contains(GameID) {
                    print("Found user/appmeta folder: " + Line)
                    UserAppMetaFolder = "/user/appmeta/" + GameID + "/"
                }
                else {
                    print("Other folder: " + Line)
                }
            }
        }
        
        Args = "curl ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + SystemDataAppMetaFolder
        cURLTask = Process()
        outpipe = Pipe()
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        cURLTask.standardOutput = outpipe
        output = [String]()
        
        LogTextView.string += "Checking " + SystemDataAppMetaFolder + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        cURLTask.launch()
        
        outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        if !output.isEmpty {
            for Line in output {
                if Line.contains(GameID) {
                    print("Found system_data/priv/appmeta folder: " + Line)
                    SystemDataAppMetaFolder = "/system_data/priv/appmeta/" + GameID + "/"
                }
                else {
                    print("Other folder: " + Line)
                }
            }
        }
        
        Args = "curl ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + NPBindFile
        cURLTask = Process()
        outpipe = Pipe()
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        cURLTask.standardOutput = outpipe
        output = [String]()
        
        LogTextView.string += "Checking " + NPBindFile + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        cURLTask.launch()
        
        outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        if !output.isEmpty {
            for Line in output {
                if Line.contains("npbind.dat") {
                    NPBindFile = "/system_data/priv/appmeta/" + GameID + "/trophy2/npbind.dat"
                    LogTextView.string += "Found /system_data/priv/appmeta/" + GameID + "/trophy2/npbind.dat\n"
                    LogTextView.scrollToEndOfDocument(nil)
                }
            }
        }
        
        return [UserAppMetaFolder, SystemDataAppMetaFolder, NPBindFile]
}
    
    func DumpUserAppMetadata(Metadata: [String], App0FolderName: String) {
        
        self.TransferProgressIndicator.isIndeterminate = false
        self.TransferProgressIndicator.maxValue = 4
        
        let UserAppMetaFolder: String = Metadata[0]
        let FTPAddress: String = "ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + UserAppMetaFolder
        let SavePath: String = SelectedDownloadFolderTextField.stringValue + "/" + App0FolderName + "/sce_sys/"
        
        let wgetTask = Process()
        wgetTask.launchPath = "/opt/homebrew/bin/wget"
        wgetTask.arguments = ["-m",
                          "-nH",
                          "--cut-dirs=3",
                          "-np",
                          "-P",
                          SavePath,
                          FTPAddress]

        var output = [String]()
        let outpipe = Pipe()
        wgetTask.standardError = outpipe

        LogTextView.string += "Dumping " + UserAppMetaFolder + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        wgetTask.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        wgetTask.waitUntilExit()
    
        if !output.isEmpty {
            for Line in output {
                if Line.contains("Downloaded:") {
                    TransferProgressIndicator.doubleValue += 1
                    DumpSystemDataAppMeta(Metadata: Metadata, App0FolderName: App0FolderName)
                }
            }
        }
  
    }
    
    func DumpSystemDataAppMeta(Metadata: [String], App0FolderName: String) {
        
        let SystemDataAppMetaFolder: String = Metadata[1]
        let FTPAddress: String = "ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + SystemDataAppMetaFolder
        let SavePath: String = SelectedDownloadFolderTextField.stringValue + "/" + App0FolderName + "/sce_sys/"
        
        let wgetTask = Process()
        wgetTask.launchPath = "/opt/homebrew/bin/wget"
        wgetTask.arguments = ["-m",
                          "-nH",
                          "--cut-dirs=4",
                          "-np",
                          "-P",
                          SavePath,
                          FTPAddress]

        var output = [String]()
        let outpipe = Pipe()
        wgetTask.standardError = outpipe

        LogTextView.string += "Dumping " + SystemDataAppMetaFolder + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        wgetTask.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        wgetTask.waitUntilExit()
    
        if !output.isEmpty {
            for Line in output {
                if Line.contains("Downloaded:") {
                    
                    TransferProgressIndicator.doubleValue += 1
                    TransferStatusTextField.stringValue = "Transfer Status : Reading npbind.dat"

                    let NPWR: String = ReadNPBind(App0FolderName: App0FolderName)
                    if !NPWR.isEmpty {
                        TransferStatusTextField.stringValue = "Transfer Status : Getting uds00.ucp"
                        GetUDS(NPWRID: NPWR, App0FolderName: App0FolderName)
                    }
                    else {
                        print("Could not retrieve NPWR id.")
                    }
                    
                }
            }
        }
        
    }
    
    func ReadNPBind(App0FolderName: String) -> String {
        
        let NPBindPath: String = SelectedDownloadFolderTextField.stringValue + "/" + App0FolderName + "/sce_sys/trophy2/npbind.dat"
        var NPWRID: String = ""

        if FileManager.default.fileExists(atPath: NPBindPath) {

            let StringsTask = Process()
            StringsTask.launchPath = "/bin/sh"
            StringsTask.arguments = ["-c", "strings " + NPBindPath]

            var output = [String]()
            let outpipe = Pipe()
            StringsTask.standardOutput = outpipe

            LogTextView.string += "Reading " + NPBindPath + "\n"
            LogTextView.scrollToEndOfDocument(nil)
            StringsTask.launch()

            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
            
            StringsTask.waitUntilExit()
        
            if !output.isEmpty {
                for Line in output {
                    if Line.contains("NPWR") {
                        NPWRID = Line
                    }
                }
            }
        }
        else {
            return ""
        }
        
        return NPWRID
    }
    
    func GetUDS(NPWRID: String, App0FolderName: String) {
        let UDSFilePath: String = "/user/np_uds/nobackup/conf/" + NPWRID + "/uds.ucp"
        let FTPAddress: String = "ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + UDSFilePath
        let SavePath: String = SelectedDownloadFolderTextField.stringValue + "/" + App0FolderName + "/sce_sys/uds/"
        
        let wgetTask = Process()
        wgetTask.launchPath = "/opt/homebrew/bin/wget"
        wgetTask.arguments = ["-P",
                          SavePath,
                          FTPAddress]

        var output = [String]()
        let outpipe = Pipe()
        wgetTask.standardError = outpipe

        LogTextView.string += "Dumping " + UDSFilePath + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        wgetTask.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        wgetTask.waitUntilExit()
    
        if !output.isEmpty {
            for Line in output {
                if Line.contains("saved") {
                    if FileManager.default.fileExists(atPath: SavePath + "uds.ucp") {
                        
                        do {
                            try FileManager.default.moveItem(atPath: SavePath + "uds.ucp", toPath: SavePath + "uds00.ucp")
                        } catch let error as NSError {
                            print("Could not rename uds.ucp: \(error)")
                        }
                        
                        TransferProgressIndicator.doubleValue += 1
                        TransferStatusTextField.stringValue = "Transfer Status : Getting trophy00.ucp"
                        GetTrophyUCP(NPWRID: NPWRID, App0FolderName: App0FolderName)
                    }
                }
            }
        }
    }
    
    func GetTrophyUCP(NPWRID: String, App0FolderName: String) {
        let TrophyUDSFilePath: String = "/user/trophy2/nobackup/conf/" + NPWRID + "/TROPHY.UCP"
        let FTPAddress: String = "ftp://" + PS5IPAddressTextField.stringValue + ":" + PS5PortTextField.stringValue + TrophyUDSFilePath
        let SavePath: String = SelectedDownloadFolderTextField.stringValue + "/" + App0FolderName + "/sce_sys/trophy2/"
        
        let wgetTask = Process()
        wgetTask.launchPath = "/opt/homebrew/bin/wget"
        wgetTask.arguments = ["-P",
                          SavePath,
                          FTPAddress]

        var output = [String]()
        let outpipe = Pipe()
        wgetTask.standardError = outpipe

        LogTextView.string += "Dumping " + TrophyUDSFilePath + "\n"
        LogTextView.scrollToEndOfDocument(nil)
        wgetTask.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        wgetTask.waitUntilExit()
    
        if !output.isEmpty {
            for Line in output {
                if Line.contains("saved") {
                    if FileManager.default.fileExists(atPath: SavePath + "TROPHY.UCP") {
                        
                        do {
                            try FileManager.default.moveItem(atPath: SavePath + "TROPHY.UCP", toPath: SavePath + "trophy00.ucp")
                        } catch let error as NSError {
                            print("Could not rename TROPHY.UCP: \(error)")
                        }
                        
                        TransferProgressIndicator.doubleValue += 1
                        TransferStatusTextField.stringValue = "Transfer Status : Metadata dumped!"
                        LogTextView.string += "Game metadata dump completed!\n"
                    }
                }
            }
        }
    }
    
    func DumpSELFFiles() -> Bool {
        
        self.TransferProgressIndicator.startAnimation(self)
        
        let netcatTask = Process()
        let Args: String = "/opt/homebrew/bin/netcat -w 3 " +
        PS5IPAddressTextField.stringValue + 
        " " +
        PS5PortTextField.stringValue +
        " | /opt/homebrew/bin/pv > " +
        SelectedDownloadFolderTextField.stringValue + "/selfdump.tar"
        
        netcatTask.launchPath = "/bin/sh"
        netcatTask.arguments = ["-c", Args]

        let OutPipe = Pipe()
        netcatTask.standardOutput = OutPipe
        let outHandle = OutPipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        Observer1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                           object: outHandle, queue: nil) {  notification -> Void in
            
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    //Update LogTextView
                    self.LogTextView.string += str as String
                    self.LogTextView.scrollToEndOfDocument(nil)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                self.TransferProgressIndicator.stopAnimation(self)
                NotificationCenter.default.removeObserver(self.Observer1!)
            }
            
        }
        
        Observer2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                           object: netcatTask, queue: nil) { notification -> Void in
            self.TransferProgressIndicator.stopAnimation(self)
            NotificationCenter.default.removeObserver(self.Observer2!)
        }
        
        netcatTask.launch()
        netcatTask.waitUntilExit()
        
        return true
    }

    @IBAction func FullDumpChecked(_ sender: NSButton) {
        MetadataOnlyRadioButton.state = NSControl.StateValue.off
        SELFOnlyRadioButton.state = NSControl.StateValue.off
    }
    
    @IBAction func MetadataDumpChecked(_ sender: NSButton) {
        CreateFullDumpRadioButton.state = NSControl.StateValue.off
        SELFOnlyRadioButton.state = NSControl.StateValue.off
    }
    
    @IBAction func SELFFilesChecked(_ sender: NSButton) {
        CreateFullDumpRadioButton.state = NSControl.StateValue.off
        MetadataOnlyRadioButton.state = NSControl.StateValue.off
    }
    
    @IBAction func StartGrabbing(_ sender: NSButton) {
        
        let FailureAlert = NSAlert()
        
        if CreateFullDumpRadioButton.state == NSControl.StateValue.on {
            
            StartButton.isEnabled = false
            TransferStatusTextField.stringValue = "Transfer Status : Dumping game files"
            
            let App0Folder = FindGameFolder()
            if App0Folder.isEmpty {
                FailureAlert.messageText = "Could not find the started game."
                FailureAlert.runModal()
                return
            }
            else {
                
                if DumpApp0(App0FolderName: App0Folder) == true {
                    
                    TransferStatusTextField.stringValue = "Transfer Status : Checking for metadata"
                    
                    let GameMetadata: [String] = CheckMetadata(App0FolderName: App0Folder)
                    if !GameMetadata.isEmpty {
                        TransferStatusTextField.stringValue = "Transfer Status : Dumping game metadata"
                        DumpUserAppMetadata(Metadata: GameMetadata, App0FolderName: App0Folder)
                        StartButton.isEnabled = true
                    }
                    else {
                        FailureAlert.messageText = "Could not find any game metadata."
                        FailureAlert.runModal()
                    }
                    
                }
                else {
                    FailureAlert.messageText = "Error while dumping."
                    FailureAlert.runModal()
                }
                
            }
        } else if MetadataOnlyRadioButton.state == NSControl.StateValue.on {
            
            StartButton.isEnabled = false
            TransferStatusTextField.stringValue = "Transfer Status : Checking for metadata"
            LogTextView.string = "Checking for game metadata\n"
            LogTextView.string += "Getting app0 game folder name\n"
            LogTextView.scrollToEndOfDocument(nil)
            
            let App0Folder = FindGameFolder()
            if !(App0Folder == "") {
                let GameMetadata: [String] = CheckMetadata(App0FolderName: App0Folder)
                if !GameMetadata.isEmpty {
                    TransferStatusTextField.stringValue = "Transfer Status : Dumping game metadata"
                    LogTextView.string += "Start dumping game metadata\n"
                    LogTextView.scrollToEndOfDocument(nil)
                    DumpUserAppMetadata(Metadata: GameMetadata, App0FolderName: App0Folder)
                    StartButton.isEnabled = true
                }
                else {
                    FailureAlert.messageText = "Could not find any game metadata."
                    FailureAlert.runModal()
                    StartButton.isEnabled = true
                }
            } else {
                FailureAlert.messageText = "Could not find the started game."
                FailureAlert.runModal()
            }
            
        } else if SELFOnlyRadioButton.state == NSControl.StateValue.on {
            
            StartButton.isEnabled = false
            TransferStatusTextField.stringValue = "Transfer Status : Dumping SELF files"
            LogTextView.string += "Start dumping SELF files, please wait...\n"
            LogTextView.scrollToEndOfDocument(nil)
            
            if DumpSELFFiles() == true {
                let CompletedAlert = NSAlert()
                CompletedAlert.messageText = "SELF files dumped to " + SelectedDownloadFolderTextField.stringValue + "/self-dump.tar"
                CompletedAlert.runModal()
                TransferStatusTextField.stringValue = "Transfer Status : SELF files dumped."
                StartButton.isEnabled = true
            } else {
                FailureAlert.messageText = "Could not dump the SELF files."
                FailureAlert.runModal()
                TransferStatusTextField.stringValue = "Transfer Status : SELF dumping failed."
                StartButton.isEnabled = true
            }
            
        }
        
    }
    
}
