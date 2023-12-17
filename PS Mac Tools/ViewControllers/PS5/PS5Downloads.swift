//
//  PS5Downloads.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 17/12/2023.
//

import Cocoa

class PS5Downloads: NSViewController, NSTableViewDelegate, NSTableViewDataSource, URLSessionDelegate, URLSessionDownloadDelegate {
    
    @IBOutlet weak var ExploitsTableView: NSTableView!
    @IBOutlet weak var HostsTableView: NSTableView!
    @IBOutlet weak var HomebrewTableView: NSTableView!
    @IBOutlet weak var DownloadButton: NSButton!
    @IBOutlet weak var DownloadProgressTextField: NSTextField!
    @IBOutlet weak var DownloadProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var CancelDownloadButton: NSButton!
    
    var DownloadURL: URL?
    var DownloadSession : URLSession?
    var DownloadSessionTask : URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AddTableItems()
        
        ExploitsTableView.delegate = self
        ExploitsTableView.dataSource = self
        HostsTableView.delegate = self
        HostsTableView.dataSource = self
        HomebrewTableView.delegate = self
        HomebrewTableView.dataSource = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    struct AvailableExploit {
        var ExploitName: String
        var ExploitInfo: String
    }
    
    struct AvailableHostOrDNS {
        var HostOrDNSName: String
        var HostOrDNSAddress: String
    }
    
    struct AvailableHomebrewOrFirmware {
        var Name: String
        var Info: String
    }
    
    var AvailableExploits = [AvailableExploit]()
    var AvailableHostsDNS = [AvailableHostOrDNS]()
    var AvailableHomebrewFirmwares = [AvailableHomebrewOrFirmware]()
    
    func AddTableItems() {
        
        AvailableExploits.append(AvailableExploit(ExploitName: "PS5 IPV6 Kernel Exploit", ExploitInfo: "3.00 - 4.51"))
        AvailableExploits.append(AvailableExploit(ExploitName: "Mast1c0re Exploit", ExploitInfo: "4.51+"))
        AvailableExploits.append(AvailableExploit(ExploitName: "JAR Loader", ExploitInfo: "7.61 and below"))

        AvailableHostsDNS.append(AvailableHostOrDNS(HostOrDNSName: "PS Multi Tools Host", HostOrDNSAddress: "http://X.X.X.X/ps5ex/"))
        AvailableHostsDNS.append(AvailableHostOrDNS(HostOrDNSName: "PKG-Zone Host", HostOrDNSAddress: "https://pkg-zone.com/exploit/PS5/index.html"))
        AvailableHostsDNS.append(AvailableHostOrDNS(HostOrDNSName: "Sleirsgoevy Host", HostOrDNSAddress: "https://sleirsgoevy.github.io/ps4jb2/ps5-403/index.html"))
        AvailableHostsDNS.append(AvailableHostOrDNS(HostOrDNSName: "Zecoxao Host", HostOrDNSAddress: "https://zecoxao.github.io/ps5jb/"))
        AvailableHostsDNS.append(AvailableHostOrDNS(HostOrDNSName: "Al Azif DNS", HostOrDNSAddress: "192.241.221.79"))
        AvailableHostsDNS.append(AvailableHostOrDNS(HostOrDNSName: "Alternative DNS", HostOrDNSAddress: "62.210.38.117"))

        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "4.03 Recovery Firwmware", Info: "Resets & ereases all content on your console."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "4.50 Recovery Firwmware", Info: "Resets & ereases all content on your console."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "4.51 Recovery Firwmware", Info: "Resets & ereases all content on your console."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "5.50 Recovery Firwmware", Info: "Resets & ereases all content on your console."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "6.00 Recovery Firwmware", Info: "Resets & ereases all content on your console."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "6.50 Recovery Firwmware", Info: "Resets & ereases all content on your console."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "4.03 System Firwmware", Info: "Updates to the corresponding system firmware."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "4.50 System Firwmware", Info: "Updates to the corresponding system firmware."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "4.51 System Firwmware", Info: "Updates to the corresponding system firmware."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "5.50 System Firwmware", Info: "Updates to the corresponding system firmware."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "6.00 System Firwmware", Info: "Updates to the corresponding system firmware."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "6.50 System Firwmware", Info: "Updates to the corresponding system firmware."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "BD-JB ELF Loader v1.6.2", Info: "Blu Ray Java exploit - up to 4.51"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "etaHEN by LightningMods", Info: "https://github.com/LightningMods/etaHEN"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "etaHEN with cheats", Info: "https://github.com/LightningMods/etaHEN"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "FTPS5", Info: "FTP Server for PS5 3.00 - 4.51"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "Homebrew Store by LightningMods", Info: "A homebrew store for the PS4/5."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "Debug Settings PKG", Info: "Installs a shortcut on the home screen to access the Debug Settings quickly."))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "Game Hub Preview PKG", Info: "Installs a 'Game Hub Preview' shortcut on the home screen"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "Internet Browser PKG", Info: "Installs a shortcut for the hidden Web Browser on the home screen"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "PS Multi Tools Host PKG", Info: "Installs a shortcut to the PS Multi Tools exploit host on the home screen"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "Store Preview PKG", Info: "Installs a 'Store Preview' shortcut on the home screen"))
        AvailableHomebrewFirmwares.append(AvailableHomebrewOrFirmware(Name: "PS5-kstuff", Info: "Enables PS4 fPKG & backups on 4.03 and 4.50"))
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "ExploitsTableViewIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "ExploitNameColumn") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ExploitNameCellView")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                
                cellView.textField?.stringValue = AvailableExploits[row].ExploitName
                
                return cellView
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "ExploitInfoColumn") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ExploitInfoCellView")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                
                cellView.textField?.stringValue = AvailableExploits[row].ExploitInfo
                
                return cellView
            } else {
                return nil
            }
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "HostsTableViewIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "HostNameColumn") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "HostNameCellView")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                
                cellView.textField?.stringValue = AvailableHostsDNS[row].HostOrDNSName
                
                return cellView
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "HostAddressColumn") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "HostAddressCellView")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                
                cellView.textField?.stringValue = AvailableHostsDNS[row].HostOrDNSAddress
                
                return cellView
            } else {
                return nil
            }
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "HomebrewTableViewIdentifier") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "NameColumn") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "NameCellView")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                
                cellView.textField?.stringValue = AvailableHomebrewFirmwares[row].Name
                
                return cellView
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "InfoClumn") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "InfoCellView")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                
                cellView.textField?.stringValue = AvailableHomebrewFirmwares[row].Info
                
                return cellView
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "ExploitsTableViewIdentifier") {
            return AvailableExploits.count
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "HostsTableViewIdentifier") {
            return AvailableHostsDNS.count
        } else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "HomebrewTableViewIdentifier") {
            return AvailableHomebrewFirmwares.count
        } else {
            return 0
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if !HomebrewTableView.selectedRowIndexes.isEmpty {
            DownloadButton.isEnabled = true
        } else {
            DownloadButton.isEnabled = false
        }
    }
    
    @IBAction func DownloadSelection(_ sender: NSButton) {
        if !HomebrewTableView.selectedRowIndexes.isEmpty {
            
            let SelectedItemName: String = AvailableHomebrewFirmwares[HomebrewTableView.selectedRow].Name
            let DownloadSessionConfig = URLSessionConfiguration.default
            
            switch SelectedItemName {
            case "4.03 Recovery Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/recovery/04.03/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "4.50 Recovery Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/recovery/04.50/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "4.51 Recovery Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/recovery/04.51/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "5.50 Recovery Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/recovery/05.50/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "6.00 Recovery Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/recovery/06.00/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "6.50 Recovery Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/recovery/06.50/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "4.03 System Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/system/04.03/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "4.50 System Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/system/04.50/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "4.51 System Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/system/04.51/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "5.50 System Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/system/05.50/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "6.00 System Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/system/06.00/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "6.50 System Firwmware":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/fw/system/06.50/PS5UPDATE.PUP")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "BD-JB ELF Loader v1.6.2":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/hb/PS5_BD-JB_ELF_Loader_v1.6.2.iso")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "etaHEN by LightningMods":
                DownloadURL = URL(string: "https://github.com/LightningMods/etaHEN/releases/download/1.11b/etaHEN-1.1b.bin")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "etaHEN with cheats":
                DownloadURL = URL(string: "https://github.com/LightningMods/etaHEN/releases/download/1.11b/etaHENwithcheats-1.1b.bin")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "FTPS5":
                DownloadURL = URL(string: "https://github.com/EchoStretch/FTPS5/releases/download/v1.4/ftps5-1.4.zip")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "Homebrew Store by LightningMods":
                DownloadURL = URL(string: "https://pkg-zone.com/Store-R2-PS5.pkg")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "Debug Settings PKG":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/pkg/DebugSettingsPS5.pkg")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "Game Hub Preview PKG":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/pkg/GameHubPreviewPS5.pkg")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "Internet Browser PKG":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/pkg/InternetBrowserPS5.pkg")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "PS Multi Tools Host PKG":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/pkg/PSMultiToolsHost.pkg")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "Store Preview PKG":
                DownloadURL = URL(string: "http://X.X.X.X/ps5/pkg/StorePreviewPS5.pkg")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            case "PS5-kstuff":
                DownloadURL = URL(string: "https://sleirsgoevy.github.io/ps4jb2/ps5-403/ps5-kstuff.bin")
                DownloadSession = URLSession(configuration: DownloadSessionConfig, delegate: self, delegateQueue: nil)
                DownloadSessionTask = DownloadSession!.downloadTask(with: DownloadURL!)
                DownloadSessionTask!.resume()
            default:
                print("No download selected.")
            }
            
        }
    }
    
    @IBAction func CancelDownload(_ sender: NSButton) {
        if DownloadSessionTask!.state == URLSessionTask.State.running {
            DownloadSessionTask!.cancel()
            
            DownloadProgressIndicator.doubleValue = 0
            CancelDownloadButton.isHidden = true
            DownloadProgressTextField.stringValue = "Progress : Download aborted."
            
            let CancelAlert = NSAlert()
            CancelAlert.messageText = "Downloader"
            CancelAlert.informativeText = "Download aborted."
            CancelAlert.addButton(withTitle: "Close")
            CancelAlert.runModal()
        }
    }
    
    func urlSession(_ dlSession: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let DownloadProgressValue = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                let NewNumberFormatter = NumberFormatter()
                NewNumberFormatter.numberStyle = .percent
                self.DownloadProgressIndicator.doubleValue = Double(DownloadProgressValue * 100)
                self.DownloadProgressTextField.stringValue = "Downloading - Progress : " + NewNumberFormatter.string(from: NSNumber(value: DownloadProgressValue))!
                
                if DownloadProgressValue * 100 == 100 {
                    let FinishAlert = NSAlert()
                    FinishAlert.messageText = "Download completed!"
                    FinishAlert.informativeText = "File downloaded to: " + FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.path
                    FinishAlert.addButton(withTitle: "Open Folder")
                    FinishAlert.addButton(withTitle: "Close")
                    
                    if FinishAlert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                    {
                        NSWorkspace.shared.open(FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!)
                        self.DownloadProgressIndicator.doubleValue = 0
                        self.CancelDownloadButton.isHidden = true
                        self.DownloadProgressTextField.stringValue = "Progress : Download completed."
                    }
                    else
                    {
                        self.DownloadProgressIndicator.doubleValue = 0
                        self.CancelDownloadButton.isHidden = true
                        self.DownloadProgressTextField.stringValue = "Progress : Download completed."
                    }
                }
        }
    }
    
    func urlSession(_ dlSession: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsUrl =  FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(self.DownloadURL!.lastPathComponent)
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: destinationUrl, atomically: true)
    }
    
}
