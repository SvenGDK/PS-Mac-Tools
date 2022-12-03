//
//  BackupManager1ViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 27/10/2022.
//

import Cocoa
import WebKit

class BackupManager1ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, WKNavigationDelegate  {
    
    
    @IBOutlet weak var gameTitleTextField: NSTextField!
    @IBOutlet weak var gamesTableView: NSTableView!
    @IBOutlet weak var gameCoverImageView: NSImageView!
    @IBOutlet var gameDescriptionTextView: NSTextView!
    
    
    var gamesList = [PS1SYSTEMCNF]()
    var selectedGamePath: String = ""
    var currentGamesPath: String = ""
    
    var gameID: String = ""
    var getProperties: Bool = true
    
    let titleJS = "document.getElementById('table4').rows[0].cells[1].textContent"
    let descriptionJS = "document.getElementById('table16').rows[0].cells[0].textContent"
    let coverJS = "document.getElementById('table2').getElementsByClassName('sectional')[1].querySelector('img').src"
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
    
    struct PS1SYSTEMCNF {
        var BOOTVAR: String
        var GAMEPATH: String
    }
    
    func runBINParser(fileInput: String) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "strings '" + fileInput + "' | LANG=C fgrep 'BOOT'"]
        
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
    
    func parseSystemCNF(inputFile: String, fullGamePath: String) -> PS1SYSTEMCNF {
        
        let BINReaderOutput = runBINParser(fileInput: inputFile).output
        
        var BINGameTitle = BINReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "BOOT = ".lowercased())
            let stringMatch2 = item.lowercased().range(of: "BOOT=".lowercased())
            if stringMatch == nil {
                return stringMatch2 != nil ? true : false
            }
            else {
                return stringMatch != nil ? true : false
            }
        })
        
        if BINGameTitle.count == 0 {
            BINGameTitle = ["Title: Title not found", "Title not found"]
        }
        
        var newGame: PS1SYSTEMCNF
        
        if BINGameTitle[0].starts(with: "BOOT=") {
            newGame = PS1SYSTEMCNF(BOOTVAR: BINGameTitle[0].components(separatedBy:  "=")[1],
                                GAMEPATH: fullGamePath)
        }
        else {
            newGame = PS1SYSTEMCNF(BOOTVAR: BINGameTitle[0].components(separatedBy: " = ")[1],
                                GAMEPATH: fullGamePath)
        }
        
        return newGame
    }
    
    func searchGameBIN(pathURL: URL) -> [String] {
        
        var foundBINs = [String]()
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
                if path.hasSuffix(".bin") {
                    foundBINs.append(path)
                }
            }
        }
        
        return foundBINs
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
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "gamePathColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "gamePathTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].GAMEPATH
            return cellView
        }
        else
        {
        }
        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return gamesList.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let id = returnGameID(bootVar: gamesList[gamesTableView.selectedRow].BOOTVAR)
        loadGameProperties(GameID: id)
    }
    
    func loadGameProperties(GameID: String) {
        let trimmedID = GameID.trimmingCharacters(in: .whitespacesAndNewlines)
        gameID = trimmedID
        let fullURL = URL(string: "https://psxdatacenter.com/plist.html")
        webVi.load(URLRequest(url: fullURL!))
    }
    
    @IBAction func loadBackupFolder(_ sender: NSButton) {
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
            
            for foundGame in searchGameBIN(pathURL: result!)
            {
                if URL(string: foundGame)?.pathExtension == "bin" {
                    print("BIN found: " + foundGame)
                    
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let getPS1plistJS = "var GAMEID = '" + gameID + "';" +
        "var DOCELEMENTS = Array.from(document.querySelectorAll('tr'));" +
        "var DOCMATCH = DOCELEMENTS.find(el => { " +
        "return el.textContent.toLowerCase().includes(GAMEID.toLowerCase());" +
        "});" +
        "DOCMATCH.getElementsByTagName('a')[0].href"
        
        if getProperties == true { //Load game properties site first
            webVi.evaluateJavaScript(getPS1plistJS) { (result, error) in
                if error == nil {
                    let gameProperties = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                    let gamePropertiesURL = URL(string: gameProperties)
                    
                    print("Found game properties: " + gameProperties)
                    self.getProperties = false
                    self.webVi.load(URLRequest(url: gamePropertiesURL!))
                }
                else {
                    self.gameTitleTextField.stringValue = "Game title not found."
                    print(error as Any)
                }
            }
        }
        else { //Now read the game properties
            
            webVi.evaluateJavaScript(titleJS) { (result, error) in
                if error == nil {

                    let gameTitle = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                    self.gameTitleTextField.stringValue = gameTitle
                    
                    self.getProperties = true
                }
                else {
                    self.gameTitleTextField.stringValue = "Game title not found."
                    self.getProperties = true
                    print(error as Any)
                }
            }
            
            webVi.evaluateJavaScript(descriptionJS) { (result, error) in
                if error == nil {
                    let trimmedDescription = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                    self.gameDescriptionTextView.string = trimmedDescription
                }
                else {
                    self.gameDescriptionTextView.string = "No description found for this game."
                }
            }
            
            webVi.evaluateJavaScript(coverJS) { (result, error) in
                if error == nil {
                    let backgroundURL = result as! String
                    let bgURL = URL(string: backgroundURL)
                    
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
    
    
}
