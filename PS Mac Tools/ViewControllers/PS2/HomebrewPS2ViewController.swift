//
//  HomebrewViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa

class HomebrewPS2ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, URLSessionDelegate, URLSessionDownloadDelegate {
    
    
    @IBOutlet weak var homebrewTable: NSTableView!
    @IBOutlet weak var downloadProgressBar: NSProgressIndicator!
    @IBOutlet weak var downloadProgressLabel: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var downloadSelectedButton: NSButton!
    
    
    var DLUrl : URL?
    var dlSession : URLSession?
    var dlTask : URLSessionTask?
    
    func urlSession(_ dlSession: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            let nf = NumberFormatter()
            nf.numberStyle = .percent
            self.downloadProgressBar.doubleValue = Double(calculatedProgress * 100)
            self.downloadProgressLabel.stringValue = nf.string(from: NSNumber(value: calculatedProgress))!
            
            if calculatedProgress * 100 == 100 {
                let alert = NSAlert()
                alert.messageText = "Finished downloading."
                alert.informativeText = "File downloaded to: " + FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.path
                alert.addButton(withTitle: "Open Folder")
                alert.addButton(withTitle: "Close")
                
                if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
                {
                    NSWorkspace.shared.open(FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!)
                    self.downloadProgressBar.doubleValue = 0
                    self.downloadProgressLabel.stringValue = ""
                    self.downloadProgressLabel.isHidden = true
                    self.downloadProgressBar.isHidden = true
                    self.cancelButton.isHidden = true
                }
                else
                {
                    self.downloadProgressBar.doubleValue = 0
                    self.downloadProgressLabel.stringValue = ""
                    self.downloadProgressLabel.isHidden = true
                    self.downloadProgressBar.isHidden = true
                    self.cancelButton.isHidden = true
                    self.downloadSelectedButton.isEnabled = true
                }
            }
            
        }
    }
    
    func urlSession(_ dlSession: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsUrl =  FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(self.DLUrl!.lastPathComponent)
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: destinationUrl, atomically: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homebrewTable.dataSource = self
        self.homebrewTable.delegate = self
        self.homebrewTable.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 700)
    }
    
    let homebrewList = [
    ["headerInfo":"Homebrew"],
        
    ["summaryInfo":"Open PS2 Loader - Stable","detailInfo":"Open PS2 Loader (OPL) is a 100% Open source game and application loader for the PS2 and PS3 units. It supports three categories of devices: USB mass storage devices, SMB shares and the PlayStation 2 HDD unit. USB devices and SMB shares support USBExtreme and *.ISO formats while PS2 HDD supports HDLoader format, all devices also support ZSO format (compressed ISO). It's now the most compatible homebrew loader. Version: 1.1.0",
     "imageIcon":"OPL"],
    ["summaryInfo":"Open PS2 Loader - Stable Languages and Fonts","detailInfo":"Open PS2 Loader (OPL) addon.",
     "imageIcon":"OPL"],
    ["summaryInfo":"Open PS2 Loader - Latest","detailInfo":"Open PS2 Loader (OPL) is a 100% Open source game and application loader for the PS2 and PS3 units. It supports three categories of devices: USB mass storage devices, SMB shares and the PlayStation 2 HDD unit. USB devices and SMB shares support USBExtreme and *.ISO formats while PS2 HDD supports HDLoader format, all devices also support ZSO format (compressed ISO). It's now the most compatible homebrew loader.\nLatest build: 238ed8e",
     "imageIcon":"OPL"],
    ["summaryInfo":"Open PS2 Loader - Latest Languages and Fonts","detailInfo":"Open PS2 Loader (OPL) addon.",
     "imageIcon":"OPL"],
        
    ["summaryInfo":"FreeMCBoot Installer","detailInfo":"Free Memory Card Boot (FMCB) Installer is a homebrew software which is designed to setup your PlayStation 2 console and provide you with a means of launching homebrew software, without the need for any extra hardware, modifications to your console or dangerous tricks like the legendary swap trick.\nLatest build: 1966-f5b2d21",
     "imageIcon":"FMCB"],
        
    ["summaryInfo":"wLaunchELF","detailInfo":"wLaunchELF, formerly known as uLaunchELF, also known as wLE or uLE (abbreviated), is an open-source file manager and executable launcher for the Playstation 2 console based on the original LaunchELF. It contains many different features, including a text editor, hard drive manager, FTP support, and much more.\nLatest build: c59d8e3",
     "imageIcon":"wLE"],
        
    ["summaryInfo":"Simple Media System","detailInfo":"Simple Media System (SMS) is a simple DivX player able to play good resolution movies at good frame rate on the unmodded PS2 without any extra equipment such as HDD and network adapter.\nCurrent Version: 2.9 (Rev.4)",
     "imageIcon":"IrisMAN"],
        
    ["summaryInfo":"HDDChecker","detailInfo":"HDDChecker is a basic disk diagnostic tool meant for testing the health of your PlayStation 2 console's Harddisk Drive unit.\nCurrent Version: 0.964",
     "imageIcon":"IDPSet"],
    ["summaryInfo":"HDDChecker FSCK Tool","detailInfo":"HDDChecker addon.\nCurrent Version: 0.964",
     "imageIcon":"IDPSet"],
        
    ["summaryInfo":"OpenTuna Installer","detailInfo":"This is the OpenTuna installer. This will install OpenTuna hacked icons and APPS folder on PS2 consoles with ROMs ranging from versions 1.10 to 2.30 (2.50?). This means OpenTuna is now compatible with Fat and Slim models from SCPH-18000 up to SCPH-90010 and PS2-TV.\nLatest build: 1.0.1-9b61aee",
     "imageIcon":"OpenTuna"],
      
    
        
    ["headerInfo":"Emulators for PS3"],
        
    ["summaryInfo":"RetroArch","detailInfo":"RetroArch is a frontend for emulators, game engines and media players. It enables you to run classic games on a wide range of computers and consoles through its slick graphical interface. \nCurrent Version: 1.13",
     "imageIcon":"RetroArch"],
        
    ["summaryInfo":"FCEUmm","detailInfo":"FCEUltra for PS2.\nCurrent Version: 0.3.3",
     "imageIcon":"RetroArch"]
      
    ]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
            return homebrewList.count
        }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            if homebrewList[row]["headerInfo"] != nil{
                let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderRow") , owner: self) as! PS2HeaderCellView
                result.homebrewHeader.stringValue = homebrewList[row]["headerInfo"]!
                    return result
                }
                            
            else{
                let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataRow") , owner: self) as! PS2DataCellView
                result.summaryTextField.stringValue = homebrewList[row]["summaryInfo"]!
                result.detailsTextField.stringValue = homebrewList[row]["detailInfo"]!
                result.imgField.image = NSImage(named: homebrewList[row]["imageIcon"]!)

                return result
            }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if homebrewList[row]["headerInfo"] != nil{
                return 30.0
            }
            else{
                return 112.0
            }
            
        }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if homebrewList[homebrewTable.selectedRow]["headerInfo"] != nil {
            downloadSelectedButton.isEnabled = false
        }
        else
        {
            downloadSelectedButton.isEnabled = true
        }
    }
    
    @IBAction func cancelDownload(_ sender: NSButton) {
        if dlTask?.state == URLSessionTask.State.running {
            dlTask?.cancel()
            
            downloadProgressBar.doubleValue = 0
            downloadProgressLabel.stringValue = ""
            downloadProgressLabel.isHidden = true
            downloadProgressBar.isHidden = true
            cancelButton.isHidden = true
            downloadSelectedButton.isEnabled = true
        }
    }
    
    @IBAction func downloadSelectedHomebrew(_ sender: NSButton) {
        
        let alert = NSAlert()
        alert.messageText = "Please confirm"
        alert.informativeText = "Do you really want to download " + homebrewList[homebrewTable.selectedRow]["summaryInfo"]!
        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            downloadProgressLabel.isHidden = false
            downloadProgressBar.isHidden = false
            cancelButton.isHidden = false
            downloadSelectedButton.isEnabled = false
            
            let selectedHB = homebrewList[homebrewTable.selectedRow]["summaryInfo"]
            let sessionConfig = URLSessionConfiguration.default
            
            if selectedHB == "Open PS2 Loader - Stable" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/v1.1.0/OPNPS2LD-v1.1.0.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "Open PS2 Loader - Stable Languages and Fonts" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/v1.1.0/OPNPS2LD-LANGUAGES-AND-FONTS-v1.1.0.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "Open PS2 Loader - Latest" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD-v1.2.0-Beta-1949-238ed8e.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "Open PS2 Loader - Latest Languages and Fonts" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/Open-PS2-Loader/releases/download/latest/OPNPS2LD-LANGS-v1.2.0-Beta-1949-238ed8e.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "FreeMCBoot Installer" {
                DLUrl = URL(string: "https://github.com/israpps/FreeMcBoot-Installer/releases/download/latest/FMCB-1966.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "wLaunchELF" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/wLaunchELF/releases/download/latest/BOOT.ELF")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "Simple Media System" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/SMS/releases/download/2.9rev4/SMS.Version.2.9.Rev.4.elf.zip")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "HDDChecker" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/HDDChecker/releases/download/v0.964/190413.HDDChecker-0964-bin.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "HDDChecker FSCK Tool" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/HDDChecker/releases/download/v0.964/190413.FSCK-tool-0987-bin.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "OpenTuna Installer" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/opentuna-installer/releases/download/latest/OpenTuna_Installer.elf")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "RetroArch" {
                DLUrl = URL(string: "https://buildbot.libretro.com/stable/1.13.0/playstation/ps2/RetroArch_elf.7z")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else if selectedHB == "FCEUmm" {
                DLUrl = URL(string: "https://github.com/ps2homebrew/Fceumm-PS2/releases/download/v0.3.3/fceu-packed.v0.3.3.cdvdsupport.elf")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            }
            else
            {
                print("Nothing selected")
            }
        }
        
}
    

class PS2DataCellView: NSTableCellView {

    @IBOutlet weak var imgField: NSImageView!
    @IBOutlet weak var detailsTextField: NSTextField!
    @IBOutlet weak var summaryTextField: NSTextField!
    
}

class PS2HeaderCellView: NSTableCellView {
    
    @IBOutlet weak var homebrewHeader: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bPath:NSBezierPath = NSBezierPath(rect: dirtyRect)
        let fillColor = NSColor.systemBlue
        fillColor.set()
        bPath.fill()
    }

}
