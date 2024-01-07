//
//  HomebrewTableViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 14/05/2021.
//

import Cocoa

class HomebrewPS3ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, URLSessionDelegate, URLSessionDownloadDelegate {
    
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
        let documentsUrl = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        let destinationUrl = documentsUrl!.appendingPathComponent(self.DLUrl!.lastPathComponent)
        let dataFromURL = NSData(contentsOf: location)
        dataFromURL?.write(to: destinationUrl, atomically: true)
    }
    
    @IBOutlet weak var homebrewTable: NSTableView!
    @IBOutlet weak var downloadSelectedButton: NSButton!
    @IBOutlet weak var downloadProgressLabel: NSTextField!
    @IBOutlet weak var downloadProgressBar: NSProgressIndicator!
    @IBOutlet weak var cancelButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homebrewTable.dataSource = self
        self.homebrewTable.delegate = self
        self.homebrewTable.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1000, height: 600)
    }
    
    let homebrewList = [
        ["headerInfo":"Homebrew"],
        ["summaryInfo":"WebMAN MOD","detailInfo":"webMAN MOD is a homebrew plugin for PlayStation®3 forked from the original webMAN/sMAN by DeanK with many features added.\nThe application provides extended services for PS3 console like web server, ftp server, file manager, netiso, ntfs, gamepad emulation, ps3mapi, tasks automation, memory debugger and more. Version: 1.47.42","imageIcon":"WebMAN"],
        
        ["summaryInfo":"IrisMAN","detailInfo":"Iris Manager fork including latest mamba from NzV.\nCurrent Version: 4.89","imageIcon":"IrisMAN"],
        

        ["summaryInfo":"IDPSet","detailInfo":"IDPSet is a tool to make CEX and DEX dump and you can permanently change your console IDPS (NAND and NOR) and change the PSID too. You just have to run IDPSet on your CFW (with eid_root_key and valid idps.bin on the root of your USB key).","imageIcon":"IDPSet"],
      
        
        ["headerInfo":"Emulators for PS3"],

        ["summaryInfo":"RetroArch","detailInfo":"RetroArch is a modular multi-system emulator system that is designed to be fast, lightweight, and portable. It has features few other emulators frontends have, such as real-time rewinding and game-aware shading.","imageIcon":"RetroArch"],
   
        
        ["headerInfo":"Firmwares"],
    
        ["summaryInfo":"Latest Official","detailInfo":"The latest official PS3 Firmware. Developed by Sony - a fork of both FreeBSD and NetBSD called CellOS. It uses XrossMediaBar (XMB) as its graphical shell.","imageIcon":"OFW"],
        ["summaryInfo":"4.87.2 Evilnat","detailInfo":"REMOVED.","imageIcon":"Evilnat"]
      
      ]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
            return homebrewList.count
        }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            if homebrewList[row]["headerInfo"] != nil{
                let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderRow") , owner: self) as! KSHeaderCellView
                result.homebrewHeader.stringValue = homebrewList[row]["headerInfo"]!
                    return result
                }
                            
            else{
                let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataRow") , owner: self) as! KSDataCellView
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
    
    @IBAction func downloadHomebrew(_ sender: NSButton) {
        
        downloadProgressLabel.isHidden = false
        downloadProgressBar.isHidden = false
        cancelButton.isHidden = false
        downloadSelectedButton.isEnabled = false
        
        let selectedHB = homebrewList[homebrewTable.selectedRow]["summaryInfo"]
        let sessionConfig = URLSessionConfiguration.default
        
        if selectedHB == "WebMAN MOD" {
            DLUrl = URL(string: "https://github.com/aldostools/webMAN-MOD/releases/download/1.47.42/webMAN_MOD_1.47.42_Installer.pkg")

            dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            dlTask = dlSession!.downloadTask(with: DLUrl!)
            dlTask!.resume()
              }
        else if selectedHB == "IrisMAN" {
            DLUrl = URL(string: "https://github.com/aldostools/IRISMAN/releases/download/4.89/IRISMAN_4.89.pkg")

            dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            dlTask = dlSession!.downloadTask(with: DLUrl!)
            dlTask!.resume()
        }
        else if selectedHB == "IDPSet" {
            DLUrl = URL(string: "https://github.com/Zarh/IDPSet/releases/download/1.93/IDPSet_v0.93.pkg")

            dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            dlTask = dlSession!.downloadTask(with: DLUrl!)
            dlTask!.resume()
        }
        else if selectedHB == "RetroArch" {
            DLUrl = URL(string: "https://xbins.org/libretro/stable/1.9.0/playstation/ps3/RetroArch.PS3.CEX.PS3.pkg")

            dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            dlTask = dlSession!.downloadTask(with: DLUrl!)
            dlTask!.resume()
        }
        else if selectedHB == "Latest Official" {
            DLUrl = URL(string: "http://duk01.ps3.update.playstation.net/update/ps3/image/uk/2022_0510_95307e1b51d3bcc33a274db91488d29f/PS3UPDAT.PUP")

            dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            dlTask = dlSession!.downloadTask(with: DLUrl!)
            dlTask!.resume()
        }
        else if selectedHB == "4.87.2 Evilnat" {
            DLUrl = URL(string: "REMOVED")

            dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            dlTask = dlSession!.downloadTask(with: DLUrl!)
            dlTask!.resume()
        }
        else
        {
            print("Nothing selected")
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
    
}

class KSDataCellView: NSTableCellView {

    @IBOutlet weak var summaryTextField:NSTextField!
    @IBOutlet weak var detailsTextField:NSTextField!
    @IBOutlet weak var imgField:NSImageView!
    
}

class KSHeaderCellView: NSTableCellView {
    
    @IBOutlet weak var homebrewHeader: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bPath:NSBezierPath = NSBezierPath(rect: dirtyRect)
        let fillColor = NSColor.systemBlue
        fillColor.set()
        bPath.fill()
    }

}
