//
//  HomebrewViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa

class HomebrewPS1ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, URLSessionDelegate, URLSessionDownloadDelegate {
    
    
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
        preferredContentSize = NSSize(width: 1300, height: 750)
    }
    
    let homebrewList = [
        ["headerInfo":"Homebrew"],
        
      ["summaryInfo":"Tonyhax International","detailInfo":"Tonyhax International is a fork of the Tonyhax 'Software backup loader exploit for the Sony PlayStation 1' originally created by Socram8888. Tonyhax International is developed by Alex Free and MottZilla with many new features and upgrades compared to the original Tonyhax.\nVersion: 1.1.5",
       "imageIcon":"TonyHax"]
    ]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
            return homebrewList.count
        }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            if homebrewList[row]["headerInfo"] != nil{
                let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderRow") , owner: self) as! PS1HeaderCellView
                result.homebrewHeader.stringValue = homebrewList[row]["headerInfo"]!
                    return result
                }
                            
            else{
                let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataRow") , owner: self) as! PS1DataCellView
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
    
    @IBAction func downloadSelectedHomebrew(_ sender: Any) {
        
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
            
            if selectedHB == "Tonyhax International" {
                DLUrl = URL(string: "https://github.com/alex-free/tonyhax/releases/download/v1.1.5i/tonyhax-v1.1.5-international.zip")

                dlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
                dlTask = dlSession!.downloadTask(with: DLUrl!)
                dlTask!.resume()
                  }
            else
            {
                print("Nothing selected")
            }
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

class PS1DataCellView: NSTableCellView {

    @IBOutlet weak var imgField: NSImageView!
    @IBOutlet weak var detailsTextField: NSTextField!
    @IBOutlet weak var summaryTextField: NSTextField!
    
}

class PS1HeaderCellView: NSTableCellView {
    
    @IBOutlet weak var homebrewHeader: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bPath:NSBezierPath = NSBezierPath(rect: dirtyRect)
        let fillColor = NSColor.systemBlue
        fillColor.set()
        bPath.fill()
    }

}
