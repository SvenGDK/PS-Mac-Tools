//
//  FTPBrowser.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 04/12/2023.
//

import Cocoa

class FTPBrowser: NSViewController, NSTableViewDelegate, NSTableViewDataSource, URLSessionDelegate, URLSessionDownloadDelegate {
    
    @IBOutlet weak var PS5FTPIPAddressTextField: NSTextField!
    @IBOutlet weak var PS5FTPPortTextField: NSTextField!
    @IBOutlet weak var FTPContentTableView: NSTableView!
    @IBOutlet weak var FTPStatusTextField: NSTextField!
    @IBOutlet weak var FTPLoadProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var CurrentPathTextField: NSTextField!
    @IBOutlet weak var CancelFTPDownloadButton: NSButton!
    
    var FTPTableViewItems = [FTPContentTableItem]()
    var CurrentFTPPath: String = ""
    var FTPContentTableContextMenu = NSMenu()
    var FTPDownloadURL: URL?
    var FTPDownloadSession: URLSession?
    var FTPDownloadTask: URLSessionTask?
    var FTPDownloadName: String?
    var BytesToWrite: Int64?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        FTPContentTableView.delegate = self
        FTPContentTableView.dataSource = self
        FTPContentTableView.doubleAction = #selector(HandleMouseDoubleClick)
        FTPContentTableView.menu = FTPContentTableContextMenu
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    struct FTPContentTableItem {
        var Permissions: String?
        var Name: String?
        var Size: String?
        var LastModified: String?
        var IsDirectory: Bool?
    }
    
    func AddTableContextMenu() {
        FTPContentTableContextMenu.addItem(NSMenuItem(title: "Download", action: #selector(DownloadSelectedItem(_:)), keyEquivalent: ""))
        FTPContentTableContextMenu.addItem(NSMenuItem(title: "New Folder", action: #selector(CreateNewFolder(_:)), keyEquivalent: ""))
        FTPContentTableContextMenu.addItem(NSMenuItem(title: "Upload", action: #selector(UploadNewItem(_:)), keyEquivalent: ""))
        FTPContentTableContextMenu.addItem(NSMenuItem(title: "Rename", action: #selector(RenameSelectedItem(_:)), keyEquivalent: ""))
        FTPContentTableContextMenu.addItem(NSMenuItem(title: "Delete", action: #selector(DeleteSelectedItem(_:)), keyEquivalent: ""))
    }
    
    func GetCurlOutput(DestinationPath: String) -> [String] {
        
        let cURLTask = Process()
        let Args:String = "curl " + DestinationPath
        
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
        
        return output
    }
    
    func ReturnAsFTPContentTableItem(Input: String) -> FTPContentTableItem {

        var FileFolderName: String = ""
        var FileFolderSize: String = ""
        var LastModifiedTime: String = ""
        var IsFolder: Bool = false
        var Permissions: String = ""
        
        let SplittedInput = Input.components(separatedBy: " ")
        if SplittedInput.indices.contains(0) {
            
            if SplittedInput[0].starts(with: "d") {
                IsFolder = true
            }
            else {
                IsFolder = false
            }
            
            let FirstCharacters: String = String(SplittedInput[0].prefix(4))
            let OwnerPermissions: String = String(FirstCharacters.dropFirst())
            
            if !OwnerPermissions.isEmpty {
                Permissions = OwnerPermissions
            }
            
        }
        if SplittedInput.indices.contains(4) {
            FileFolderSize = SplittedInput[4]
        }
        if SplittedInput.indices.contains(5) && SplittedInput.indices.contains(6) && SplittedInput.indices.contains(7) {
            LastModifiedTime = SplittedInput[5] + " " + SplittedInput[6] + " " + SplittedInput[7]
        }
        if SplittedInput.indices.contains(8) {
            FileFolderName = SplittedInput[8]
        }
        
        if !FileFolderName.isEmpty {
            return FTPContentTableItem(Permissions: Permissions, Name: FileFolderName, Size: FileFolderSize, LastModified: LastModifiedTime, IsDirectory: IsFolder)
        }
        else {
            return FTPContentTableItem()
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return FTPTableViewItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "FileOrFolderNameColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "FileOrFolderNameCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            if !FTPTableViewItems.isEmpty {
                cellView.textField?.stringValue = FTPTableViewItems[row].Name!
                
                if FTPTableViewItems[row].IsDirectory == true {
                    cellView.imageView?.image = NSImage(systemSymbolName: "folder.fill", accessibilityDescription: nil)
                }
                else {
                    cellView.imageView?.image = NSImage(systemSymbolName: "doc.fill", accessibilityDescription: nil)
                }
            }
            
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "SizeColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "SizeCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            if !FTPTableViewItems.isEmpty {
                
                let ItemSize = Int64(FTPTableViewItems[row].Size!)
                let SizeWithUnit = ByteCountFormatter.string(fromByteCount: ItemSize!, countStyle: .file)
                
                cellView.textField?.stringValue = SizeWithUnit
            }
            
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "LastModifiedColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "LastModifiedCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            
            if !FTPTableViewItems.isEmpty {
                cellView.textField?.stringValue = FTPTableViewItems[row].LastModified!
            }
            
            return cellView
        }
        else
        {
            return nil
        }
    }
    
    @IBAction func ConnectToFTP(_ sender: NSButton) {
        
        if !PS5FTPIPAddressTextField.stringValue.isEmpty && !PS5FTPPortTextField.stringValue.isEmpty {
            
            AddTableContextMenu()
            CurrentPathTextField.stringValue = "Current path : /"
            CurrentFTPPath = "ftp://" + PS5FTPIPAddressTextField.stringValue + ":" + PS5FTPPortTextField.stringValue + "/"
            
            let FTPContentOutput = GetCurlOutput(DestinationPath: CurrentFTPPath)
            for FTPContent in FTPContentOutput {
                let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                FTPTableViewItems.append(NewFTPContentTableItem)
            }
           
            FTPContentTableView.reloadData()
        }
        else {
            
        }
        
    }
    
    @objc func HandleMouseDoubleClick() {
        let SelectedRow: Int = FTPContentTableView.selectedRow
        let SelectedItem: FTPContentTableItem = FTPTableViewItems[SelectedRow]
        let NextFTPItemName = SelectedItem.Name!
        
        if SelectedItem.IsDirectory == true {
            // Handle directories
            if NextFTPItemName == ".." {
                
                let BasePath: String = "ftp://" + PS5FTPIPAddressTextField.stringValue + ":" + PS5FTPPortTextField.stringValue + "/"
                       
                if !(CurrentFTPPath == BasePath) {
                    // Go back if its not the base path
                    let DirAsURL: URL = URL(string: CurrentFTPPath)!
                    let NextDirectoryPath: String = DirAsURL.deletingLastPathComponent().absoluteString
                    let FTPContentOutput = GetCurlOutput(DestinationPath: NextDirectoryPath)
                    
                    CurrentFTPPath = NextDirectoryPath
                    CurrentPathTextField.stringValue = "Current path : " + DirAsURL.deletingLastPathComponent().path
                    FTPTableViewItems.removeAll()
                    
                    for FTPContent in FTPContentOutput {
                        let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                        FTPTableViewItems.append(NewFTPContentTableItem)
                    }
                    
                }
                else {
                    // Reload the current path
                    let FTPContentOutput = GetCurlOutput(DestinationPath: CurrentFTPPath)
                    
                    FTPTableViewItems.removeAll()
                    
                    for FTPContent in FTPContentOutput {
                        let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                        FTPTableViewItems.append(NewFTPContentTableItem)
                    }
                    
                }
                
            }
            else {
                // Change to the selected directory
                let NewDestinationPath = CurrentFTPPath + NextFTPItemName + "/"
                let FTPContentOutput = GetCurlOutput(DestinationPath: NewDestinationPath)
                let NewDestinationPathAsURL: URL = URL(string: NewDestinationPath)!
                
                CurrentFTPPath = NewDestinationPath
                CurrentPathTextField.stringValue = "Current path : " + NewDestinationPathAsURL.path
                FTPTableViewItems.removeAll()
                
                for FTPContent in FTPContentOutput {
                    let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                    FTPTableViewItems.append(NewFTPContentTableItem)
                }
                
            }
            
            FTPContentTableView.reloadData()
        }
    }
    
    func urlSession(_ dlSession: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let CalculatedProgress = Float(totalBytesWritten) / Float(BytesToWrite!)
        
        DispatchQueue.main.async {
            
            let DownloadNumberFormatter = NumberFormatter()
            DownloadNumberFormatter.numberStyle = .percent
            
            self.FTPLoadProgressIndicator.doubleValue = Double(CalculatedProgress * 100)
            self.FTPStatusTextField.stringValue = "Downloading : " + self.FTPDownloadName! + " - Progress : " + DownloadNumberFormatter.string(from: NSNumber(value: CalculatedProgress))!
            
            if CalculatedProgress * 100 == 100 {
                
                let FinishAlert = NSAlert()
                FinishAlert.messageText = "Finished downloading."
                FinishAlert.informativeText = "File downloaded to: " + FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.path
                FinishAlert.addButton(withTitle: "Open Folder")
                FinishAlert.addButton(withTitle: "Close")
                
                if FinishAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                {
                    NSWorkspace.shared.open(FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!)
                }
                
                self.FTPLoadProgressIndicator.doubleValue = 0
                self.FTPStatusTextField.stringValue = "Downloaded : " + self.FTPDownloadName!
            }
            
        }
    }
    
    func urlSession(_ dlSession: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsUrl =  FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(self.FTPDownloadURL!.lastPathComponent)
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: destinationUrl, atomically: true)
    }
    
    @objc private func DownloadSelectedItem(_ sender: AnyObject) {

        if !FTPContentTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = FTPContentTableView.selectedRow
            let SelectedItem: FTPContentTableItem = FTPTableViewItems[SelectedRow]
            let NextFTPItemName = SelectedItem.Name!
            let isDirectory = SelectedItem.IsDirectory
            let ItemSize = Int64(SelectedItem.Size!)
            let URLSessionConfig = URLSessionConfiguration.default
            
            if isDirectory == false {
                
                CancelFTPDownloadButton.isEnabled = true
                CancelFTPDownloadButton.isHidden = false
                
                BytesToWrite = ItemSize
                FTPDownloadName = NextFTPItemName
                FTPDownloadURL = URL(string: CurrentFTPPath + NextFTPItemName)
                FTPDownloadSession = URLSession(configuration: URLSessionConfig, delegate: self, delegateQueue: nil)
                FTPDownloadTask = FTPDownloadSession!.downloadTask(with: FTPDownloadURL!)
                FTPDownloadTask!.resume()

            }
        }
        
    }
    
    @IBAction func CancelDownload(_ sender: NSButton) {
        if FTPDownloadTask!.state == URLSessionTask.State.running {
            FTPDownloadTask!.cancel()
            
            FTPLoadProgressIndicator.doubleValue = 0
            CancelFTPDownloadButton.isEnabled = false
            CancelFTPDownloadButton.isHidden = true
            
            let CancelAlert = NSAlert()
            CancelAlert.messageText = "FTP Browser"
            CancelAlert.informativeText = "Download aborted."
            CancelAlert.addButton(withTitle: "Close")
            CancelAlert.runModal()
        }
    }
    
    func UploadToFTP(FileOrFolder: String, DestinationPath: String) -> Bool {
        let cURLTask = Process()
        let Args:String = "curl -T '" + FileOrFolder + "' " + DestinationPath
        
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        
        var output = [String]()
        let outpipe = Pipe()
        cURLTask.standardError = outpipe
        
        cURLTask.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        for Line in output {
            if Line.contains("command failed") || Line.contains("Send failure:") {
                return false
            }
        }
        
        return true
    }
    
    @objc private func UploadNewItem(_ sender: AnyObject) {

        if !FTPTableViewItems.isEmpty {
            
            let OpenDialog = NSOpenPanel()
            OpenDialog.title = "Choose a file to upload"
            OpenDialog.showsResizeIndicator = true
            OpenDialog.showsHiddenFiles = false
            OpenDialog.canChooseFiles = true
            OpenDialog.canChooseDirectories = false
            OpenDialog.allowsMultipleSelection = false
            
            if (OpenDialog.runModal() ==  NSApplication.ModalResponse.OK) {
                let result = OpenDialog.url
                
                if result!.isFileURL == true {
                    
                    let DestinationFileName: String = result!.lastPathComponent
                       
                    //Upload the file
                    if UploadToFTP(FileOrFolder: result!.path, DestinationPath: CurrentFTPPath + DestinationFileName) == true {
                        FTPStatusTextField.stringValue = "Status : Uploaded " + DestinationFileName + "."
                        
                        //Reload FTP content
                        let FTPContentOutput = GetCurlOutput(DestinationPath: CurrentFTPPath)
                        
                        FTPTableViewItems.removeAll()
                        
                        for FTPContent in FTPContentOutput {
                            let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                            FTPTableViewItems.append(NewFTPContentTableItem)
                        }
                       
                        FTPContentTableView.reloadData()
                    }
                    else {
                        FTPStatusTextField.stringValue =  "Status : Could not upload " + DestinationFileName
                    }
                    
                }
                
            }
    
        }
        
    }
    
    func CreateNewFTPFolder(NewFolderName: String, DestinationPath: String) -> Bool {
        let cURLTask = Process()
        let DestinationPathAsURL: URL = URL(string: DestinationPath)!
        let DestinationFTPServer: String = DestinationPathAsURL.host! + ":" + (DestinationPathAsURL.port!.description)
        let DestinationFolder: String = DestinationPathAsURL.path + "/"
        
        let Args:String = "curl -Q \"+MTRW\" ftp://" + DestinationFTPServer + " -Q \"MKD " + DestinationFolder + NewFolderName + "\""
        
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        
        var output = [String]()
        let outpipe = Pipe()
        cURLTask.standardError = outpipe
        
        cURLTask.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        for Line in output {
            if Line.contains("command failed") {
                return false
            }
        }
        
        return true
    }
    
    @objc private func CreateNewFolder(_ sender: AnyObject) {

        if !FTPTableViewItems.isEmpty {
            
            let NewFolderAlert = NSAlert()
            let NewFolderNameTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            
            NewFolderNameTextField.stringValue = ""
            NewFolderAlert.accessoryView = NewFolderNameTextField
            NewFolderAlert.messageText = "FTP Browser"
            NewFolderAlert.informativeText = "Enter a name for the new folder :"
            NewFolderAlert.addButton(withTitle: "Create")
            NewFolderAlert.addButton(withTitle: "Cancel")
            
            let AlertResponse: NSApplication.ModalResponse = NewFolderAlert.runModal()

            if (AlertResponse == NSApplication.ModalResponse.alertFirstButtonReturn) {

                //Rename the file or folder
                if CreateNewFTPFolder(NewFolderName: NewFolderNameTextField.stringValue, DestinationPath: CurrentFTPPath) == true {
                    FTPStatusTextField.stringValue = "Status : Folder " + NewFolderNameTextField.stringValue + " created."
                    
                    //Reload FTP content
                    let FTPContentOutput = GetCurlOutput(DestinationPath: CurrentFTPPath)
                    
                    FTPTableViewItems.removeAll()
                    
                    for FTPContent in FTPContentOutput {
                        let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                        FTPTableViewItems.append(NewFTPContentTableItem)
                    }
                   
                    FTPContentTableView.reloadData()
                }
                else {
                    FTPStatusTextField.stringValue =  "Status : Could create the folder " + NewFolderNameTextField.stringValue
                }
                
            }
            
        }
        
    }
    
    func RenameFileOrFolder(OldName: String, NewName: String, DestinationPath: String) -> Bool {
        let cURLTask = Process()
        let Args:String = "curl -Q \"-RNFR " + OldName + "\" -Q \"-RNTO " + NewName + "\" " + DestinationPath
        
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        
        var output = [String]()
        let outpipe = Pipe()
        cURLTask.standardError = outpipe
        
        cURLTask.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        for Line in output {
            if Line.contains("not accepted:") {
                return false
            }
        }
        
        return true
    }
    
    @objc private func RenameSelectedItem(_ sender: AnyObject) {

        if !FTPContentTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = FTPContentTableView.selectedRow
            let SelectedItem: FTPContentTableItem = FTPTableViewItems[SelectedRow]
            let NextFTPItemName = SelectedItem.Name!
            let RenameAlert = NSAlert()
            let RenameInputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            
            RenameInputTextField.stringValue = NextFTPItemName
            RenameAlert.accessoryView = RenameInputTextField
            RenameAlert.messageText = "FTP Browser"
            RenameAlert.informativeText = "Enter a new name for :"
            RenameAlert.addButton(withTitle: "Rename")
            RenameAlert.addButton(withTitle: "Cancel")
            
            let AlertResponse: NSApplication.ModalResponse = RenameAlert.runModal()

            if (AlertResponse == NSApplication.ModalResponse.alertFirstButtonReturn) {
                
                //Rename the file or folder
                if RenameFileOrFolder(OldName: NextFTPItemName, NewName: RenameInputTextField.stringValue, DestinationPath: CurrentFTPPath) == true {
                    FTPStatusTextField.stringValue = "Status : File " + NextFTPItemName + " renamed to " + RenameInputTextField.stringValue
                    
                    //Reload FTP content
                    let FTPContentOutput = GetCurlOutput(DestinationPath: CurrentFTPPath)
                    
                    FTPTableViewItems.removeAll()
                    
                    for FTPContent in FTPContentOutput {
                        let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                        FTPTableViewItems.append(NewFTPContentTableItem)
                    }
                   
                    FTPContentTableView.reloadData()
                }
                else {
                    FTPStatusTextField.stringValue =  "Status : Could not rename " + NextFTPItemName
                }
                
            }
            
        }
        
    }
    
    func DeleteFileOrFolderFromFTP(FileFolderName: String, DestinationPath: String) -> Bool {
        let cURLTask = Process()
        let DestinationPathAsURL: URL = URL(string: DestinationPath)!
        let DestinationFTPServer: String = DestinationPathAsURL.host! + ":" + (DestinationPathAsURL.port!.description)
        let DestinationFolder: String = DestinationPathAsURL.path + "/"
        
        let Args:String = "curl -Q \"+MTRW\" ftp://" + DestinationFTPServer + " -Q \"DELE " + DestinationFolder + FileFolderName + "\""
        
        cURLTask.launchPath = "/bin/sh"
        cURLTask.arguments = ["-c", Args]
        
        var output = [String]()
        let outpipe = Pipe()
        cURLTask.standardError = outpipe
        
        cURLTask.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        cURLTask.waitUntilExit()
        
        for Line in output {
            if Line.contains("command failed") {
                return false
            }
        }
        
        return true
    }
    
    @objc private func DeleteSelectedItem(_ sender: AnyObject) {

        if !FTPContentTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = FTPContentTableView.selectedRow
            let SelectedItem: FTPContentTableItem = FTPTableViewItems[SelectedRow]
            let NextFTPItemName = SelectedItem.Name!
            let IsDirectory = SelectedItem.IsDirectory
            let DeleteAlert = NSAlert()
            
            DeleteAlert.messageText = "FTP Browser"
            
            if IsDirectory == true {
                DeleteAlert.informativeText = "Do you really want to delete this folder ?"
            }
            else {
                DeleteAlert.informativeText = "Do you really want to delete this file ?"
            }
  
            DeleteAlert.addButton(withTitle: "Delete")
            DeleteAlert.addButton(withTitle: "Cancel")
            
            let AlertResponse: NSApplication.ModalResponse = DeleteAlert.runModal()

            if (AlertResponse == NSApplication.ModalResponse.alertFirstButtonReturn) {
                
                //Rename the file or folder
                if DeleteFileOrFolderFromFTP(FileFolderName: NextFTPItemName, DestinationPath: CurrentFTPPath) == true {
                    
                    if IsDirectory == true {
                        FTPStatusTextField.stringValue = "Status : Folder " + NextFTPItemName + " deleted."
                    }
                    else {
                        FTPStatusTextField.stringValue = "Status : File " + NextFTPItemName + " deleted."
                    }
    
                    //Reload FTP content
                    let FTPContentOutput = GetCurlOutput(DestinationPath: CurrentFTPPath)
                    
                    FTPTableViewItems.removeAll()
                    
                    for FTPContent in FTPContentOutput {
                        let NewFTPContentTableItem = ReturnAsFTPContentTableItem(Input: FTPContent)
                        FTPTableViewItems.append(NewFTPContentTableItem)
                    }
                   
                    FTPContentTableView.reloadData()
                }
                else {
                    FTPStatusTextField.stringValue =  "Status : Could not delete " + NextFTPItemName
                }
                
            }
            
        }
        
    }
    
}
