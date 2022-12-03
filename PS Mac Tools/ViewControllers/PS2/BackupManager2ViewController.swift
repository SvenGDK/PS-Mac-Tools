//
//  BackupManager2ViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 27/10/2022.
//

import Cocoa
import WebKit

class BackupManager2ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, WKNavigationDelegate {
    
    
    @IBOutlet weak var gamesTableView: NSTableView!
    
    @IBOutlet weak var loadBackupsButton: NSButton!
    @IBOutlet weak var gameCoverImageView: NSImageView!
    @IBOutlet weak var gameTitleTextField: NSTextField!
    @IBOutlet var descriptionTextView: NSTextView!
    
    var gamesList = [PS2SystemCNF]()
    var selectedGamePath: String = ""
    var currentGamesPath: String = ""
    
    let PS2Database = URL(string: "https://psxdatacenter.com/psx2/games2/")
    let coverJS = "document.getElementById('table2').getElementsByClassName('sectional')[1].querySelector('img').src"
    let titleJS = "document.getElementById('table4').rows[0].cells[1].textContent"
    let descriptionJS = "document.getElementById('table16').rows[0].cells[0].textContent"
    var webVi = WKWebView()
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        webVi.navigationDelegate = self
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        gamesTableView.reloadData()
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 1300, height: 750)
    }
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    fileprivate func fileExistsAtPath(_ path: String) -> Bool {
        let exists = FileManager.default.fileExists(atPath: path)
        return exists
    }
    
    struct PS2SystemCNF {
        var BOOTVAR: String
        var VER: String
        var VMODE: String
        var GAMEPATH: String
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
    
    func parseSystemCNF(inputFile: String, fullGamePath: String) -> PS2SystemCNF {
        
        let ISOReaderOutput = runISOParser(fileInput: inputFile).output
        
        var ISOGameTitle = ISOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "BOOT2 = ".lowercased())
            let stringMatch2 = item.lowercased().range(of: "BOOT2=".lowercased())
            if stringMatch == nil {
                return stringMatch2 != nil ? true : false
            }
            else {
                return stringMatch != nil ? true : false
            }
        })
        
        var ISOGameVer = ISOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "VER = ".lowercased())
            let stringMatch2 = item.lowercased().range(of: "VER=".lowercased())
            if stringMatch == nil {
                return stringMatch2 != nil ? true : false
            }
            else {
                return stringMatch != nil ? true : false
            }
        })
        
        var ISOGameVMode = ISOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "VMODE = ".lowercased())
            let stringMatch2 = item.lowercased().range(of: "VMODE=".lowercased())
            if stringMatch == nil {
                return stringMatch2 != nil ? true : false
            }
            else {
                return stringMatch != nil ? true : false
            }
        })
        
        if ISOGameTitle.count == 0 {
            ISOGameTitle = ["Title: Title not found", "Title not found"]
        }
        
        if ISOGameVer.count == 0 {
            ISOGameVer = ["ID: Not found", "No ID"]
        }
        
        if ISOGameVMode .count == 0 {
            ISOGameVMode = ["Game Version: Not found", "No Version"]
        }
        
        var newGame: PS2SystemCNF
        
        if ISOGameTitle[0].starts(with: "BOOT2=") {
            newGame = PS2SystemCNF(BOOTVAR: ISOGameTitle[0].components(separatedBy:  "=")[1],
                                  VER: ISOGameVer[0].components(separatedBy: "=")[1],
                                  VMODE: ISOGameVMode[0].components(separatedBy: "=")[1],
                                GAMEPATH: fullGamePath)
        }
        else {
            newGame = PS2SystemCNF(BOOTVAR: ISOGameTitle[0].components(separatedBy: " = ")[1],
                                  VER: ISOGameVer[0].components(separatedBy: " = ")[1],
                                  VMODE: ISOGameVMode[0].components(separatedBy: " = ")[1],
                                GAMEPATH: fullGamePath)
        }
        
        return newGame
    }
    
    func searchGameISO(pathURL: URL) -> [String] {
        
        var foundISOs = [String]()
        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]
        
        let enumerator = fileManager.enumerator(
            at: pathURL,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(url, error) -> Bool in
                return true
            })
        
        if enumerator != nil {
            while let file = enumerator!.nextObject() {
                let path = URL(fileURLWithPath: (file as! URL).absoluteString, relativeTo: pathURL).path
                if path.hasSuffix(".iso") {
                    foundISOs.append(path)
                }
            }
        }
        
        return foundISOs
    }
    
    func returnGameID(bootVar: String) -> String {
        return bootVar.components(separatedBy: ":\\")[1].replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: "_", with: "-", options: NSString.CompareOptions.literal, range: nil).replacingOccurrences(of: ";1", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "gameIDColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "gameIDTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = returnGameID(bootVar: gamesList[row].BOOTVAR)
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "versionColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "versionTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].VER
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "regionColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "regionTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].VMODE
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "pathColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "pathTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].GAMEPATH
            return cellView
        }
        else
        {
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let id = returnGameID(bootVar: gamesList[gamesTableView.selectedRow].BOOTVAR)
        loadDatabaseContent(GameID: id)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return gamesList.count
    }
    
    @IBAction func loadBackupsFolder(_ sender: NSButton) {
        let FolderBrowserPanel = NSOpenPanel()
        
        FolderBrowserPanel.title = "Choose your games folder"
        FolderBrowserPanel.showsResizeIndicator = true
        FolderBrowserPanel.showsHiddenFiles = false
        FolderBrowserPanel.canChooseFiles = false
        FolderBrowserPanel.canChooseDirectories = true
        FolderBrowserPanel.allowsMultipleSelection = false
        
        if (FolderBrowserPanel.runModal() ==  NSApplication.ModalResponse.OK) {
            gamesList.removeAll()
            let result = FolderBrowserPanel.url
            currentGamesPath = result!.path
            
            for foundGame in searchGameISO(pathURL: result!)
            {
                if URL(string: foundGame)?.pathExtension == "iso" {
                    print("ISO found: " + foundGame)
                    
                    var gamePath: String = foundGame.components(separatedBy: "file:")[1]
                    var url = URL(fileURLWithPath: gamePath)
                    
                    if gamePath.contains("%20"){
                        gamePath = gamePath.removingPercentEncoding ?? gamePath
                        url = URL(fileURLWithPath: gamePath)
                    }
                    
                    if !gamePath.contains("/PSMT/") {
                        gamesList.append(parseSystemCNF(inputFile: gamePath, fullGamePath: url.path))
                    }
                    
                }
                
            }
            
            gamesTableView.reloadData()
            
        } else {
            return
        }
    }
    
    func loadDatabaseContent(GameID: String) {
        let trimmedID = GameID.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullURL = URL(string: "https://psxdatacenter.com/psx2/games2/" + trimmedID + ".html")
        webVi.load(URLRequest(url: fullURL!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webVi.evaluateJavaScript(titleJS) { (result, error) in
            if error == nil {
                let trimmedGameTitle = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                self.gameTitleTextField.stringValue = trimmedGameTitle
            }
            else {
                self.gameTitleTextField.stringValue = "Game title not found."
            }
        }
        
        webVi.evaluateJavaScript(descriptionJS) { (result, error) in
            if error == nil {
                let trimmedDescription = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                self.descriptionTextView.string = trimmedDescription
            }
            else {
                self.descriptionTextView.string = "No description found for this game."
            }
        }
        
        webVi.evaluateJavaScript(coverJS) { (result, error) in
            if error == nil {
                let backgroundURL = result as! String
                let bgURL = URL(string: backgroundURL)
                print("Cover URL: " + backgroundURL)
                
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: bgURL!) {
                            if let image = NSImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.gameCoverImageView.image = image
                                }
                            }
                    }
                }
            }
            else
            {
                self.gameCoverImageView.image = nil
            }
        }
        
    }
    
}
