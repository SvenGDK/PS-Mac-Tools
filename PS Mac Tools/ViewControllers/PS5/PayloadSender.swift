//
//  PayloadSender.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 04/12/2023.
//

import Cocoa

class PayloadSender: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    
    @IBOutlet weak var PayloadTableView: NSTableView!
    @IBOutlet weak var PS5IPTextField: NSTextField!
    @IBOutlet weak var PS5PortTextField: NSTextField!
    @IBOutlet weak var SelectedPayloadPathTextField: NSTextField!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        PayloadTableView.delegate = self
        PayloadTableView.dataSource = self
        PayloadTableView.reloadData()
        
        AddPayloadsToList()
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    struct PayloadTableItem {
        var PayloadName: String
        var PayloadInfo: String
    }
    
    var PayloadTableItems = [PayloadTableItem]()
    
    func AddPayloadsToList() {
        PayloadTableItems.append(PayloadTableItem(PayloadName: "FTPS5-Persistent", PayloadInfo: "FTP server for PS5. [v1.4]"))
        PayloadTableItems.append(PayloadTableItem(PayloadName: "FTPS5-NonPersistent", PayloadInfo: "FTP server for PS5. [v1.4]"))
        PayloadTableItems.append(PayloadTableItem(PayloadName: "kstuff", PayloadInfo: "fself and fpkg support (4.5x & 4.03 only)"))
        PayloadTableItems.append(PayloadTableItem(PayloadName: "etaHEN", PayloadInfo: "AiO Homebrew Enabler [v1.1b]"))
        PayloadTableItems.append(PayloadTableItem(PayloadName: "mast1c0re Network Game Loader", PayloadInfo: "Load PS2 ISO games over the network using the mast1c0re vulnerability."))
        PayloadTableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "PayloadTitleColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PayloadNameTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = PayloadTableItems[row].PayloadName
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "PayloadInfoColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PayloadInfoTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = PayloadTableItems[row].PayloadInfo
            return cellView
        }
        else
        {
            return nil
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return PayloadTableItems.count
    }
    
    @IBAction func BrowsePayloadFile(_ sender: NSButton) {
        
        let dialog = NSOpenPanel()

        dialog.title = "Select your payload"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            SelectedPayloadPathTextField.stringValue = result!.path
        }
        
    }
    
    @IBAction func SendCustomPayload(_ sender: NSButton) {
        
        let SelectedPayloadFileName: String = URL(string: SelectedPayloadPathTextField.stringValue)!.lastPathComponent
        let SendAlert = NSAlert()
        SendAlert.messageText = "Send Payload"
        SendAlert.informativeText = "Send " + SelectedPayloadFileName + " to " + PS5IPTextField.stringValue + " ?"
        SendAlert.addButton(withTitle: "Yes")
        SendAlert.addButton(withTitle: "Cancel")
        
        if SendAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let SendTask = Process()
            SendTask.launchPath = "/bin/sh"
            SendTask.arguments = ["-c", "nc -w 0 " + PS5IPTextField.stringValue + " " + PS5PortTextField.stringValue + " < '" + SelectedPayloadPathTextField.stringValue + "'"]
    
            let OutputPipe = Pipe()
            SendTask.standardOutput = OutputPipe

            SendTask.launch()

            let outdata = OutputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outdata, as: UTF8.self)

            SendTask.waitUntilExit()
            
            print(output)
            
            let SendSuccessAlert = NSAlert()
            SendSuccessAlert.messageText = "Payload Sent!"
            SendSuccessAlert.informativeText = SelectedPayloadFileName + " has been sent to the PS5."
            SendSuccessAlert.addButton(withTitle: "Close")
    
            SendSuccessAlert.runModal()
        }
        
    }
    
    
    @IBAction func SendSelectedPayload(_ sender: NSButton) {
        
        var PayloadAppPath: String = ""
        
        let SelectedPayloadName: String = PayloadTableItems[PayloadTableView.selectedRow].PayloadName
        switch SelectedPayloadName {
        case "FTPS5-Persistent":
            PayloadAppPath = Bundle.main.path(forResource: "ftps5-p.elf", ofType: "")!
        case "FTPS5-NonPersistent":
            PayloadAppPath = Bundle.main.path(forResource: "ftps5-np.elf", ofType: "")!
        case "kstuff":
            PayloadAppPath = Bundle.main.path(forResource: "ps5-kstuff.elf", ofType: "")!
        case "etaHEN":
            PayloadAppPath = Bundle.main.path(forResource: "etaHEN-1.1b.bin", ofType: "")!
        case "mast1c0re Network Game Loader":
            PayloadAppPath = Bundle.main.path(forResource: "mast1c0re-ps2-network-game-loader-PS5-6-50.elf", ofType: "")!
        default:
            print("No valid payload selected.")
            break
        }
        
        SendCustomPayload(PayloadFile: PayloadAppPath)
    }
    
    func SendCustomPayload(PayloadFile: String) {
        let PayloadFileName: String = URL(string: PayloadFile)!.lastPathComponent
        let SendAlert = NSAlert()
        SendAlert.messageText = "Send Payload"
        SendAlert.informativeText = "Send " + PayloadFileName + " to " + PS5IPTextField.stringValue + " ?"
        SendAlert.addButton(withTitle: "Yes")
        SendAlert.addButton(withTitle: "Cancel")
        
        if SendAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            let SendTask = Process()
            SendTask.launchPath = "/bin/sh"
            SendTask.arguments = ["-c", "nc -w 0 " + PS5IPTextField.stringValue + " " + PS5PortTextField.stringValue + " < '" + PayloadFile + "'"]
    
            let OutputPipe = Pipe()
            SendTask.standardOutput = OutputPipe

            SendTask.launch()

            let outdata = OutputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outdata, as: UTF8.self)

            SendTask.waitUntilExit()
            
            print(output)
            
            let SendSuccessAlert = NSAlert()
            SendSuccessAlert.messageText = "Payload Sent!"
            SendSuccessAlert.informativeText = PayloadFileName + " has been sent to the PS5."
            SendSuccessAlert.addButton(withTitle: "Close")
    
            SendSuccessAlert.runModal()
        }
    }
    
}
