//
//  BackupManager4ViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 27/10/2022.
//

import Cocoa
import WebKit

class BackupManager4ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, WKNavigationDelegate {
    
    @IBOutlet weak var gamesTableView: NSTableView!
    @IBOutlet weak var GameIDTextField: NSTextField!
    @IBOutlet weak var ContentIDTextField: NSTextField!
    @IBOutlet weak var VersionTextField: NSTextField!
    @IBOutlet weak var CategoryTextField: NSTextField!
    @IBOutlet weak var GameTitleTextField: NSTextField!
    @IBOutlet weak var DescriptionTextField: NSTextField!
    @IBOutlet weak var LoadBackupFolderButton: NSButton!
    @IBOutlet weak var CopyBackupButton: NSButton!
    @IBOutlet weak var BackgroundImage: NSImageView!
    @IBOutlet weak var AppImage: NSImageView!

    var gamesList = [PS4Game]()
    var selectedGamePath: String = ""
    var currentGamesPath: String = ""
    var backgroundAudioPlayer: Process = Process()
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
    
    struct PS4Game {
        var TITLE: String
        var TITLE_ID: String
        var VERSION: String
        var CONTENT_ID: String
        var CATEGORY: String
        var PARENTAL_LEVEL: String
        var GAMEPATH: String
    }
    
    let StoreURL = URL(string: "https://store.playstation.com/product/")!
    let BackgroundJS = "document.querySelector('img').src"
    let StoreDetailsJS = "document.getElementById('mfe-jsonld-tags').innerHTML"
    struct StorePage: Decodable {
        let name: String
        let category: String
        let description: String
        let image: String
    }
    
    func runSFOParser(fileInput: String) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let sfoutil = Bundle.main.path(forResource: "sfoutil", ofType: "")
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "'" + sfoutil! + "' '" + fileInput + "'"]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
    
    func ReturnCategory(shortCategory: String) -> String {
        switch shortCategory {
        case "ac":
            return "Additional Content"
        case "bd":
            return "Blu-ray Disc"
        case "gd":
            return "Game Digital Application"
        case "gdc":
            return "Non-Game Big Application"
        case "gdd":
            return "BG Application"
        case "gde":
            return "Non-Game Mini App / Video Service Native App"
        case "gdk":
            return "Video Service Web App"
        case "gdl":
            return "PS Cloud Beta App"
        case "gdO":
            return "PS2 Classic"
        case "gp":
            return "Game Application Patch"
        case "gpe":
            return "Non-Game Mini App Patch / Video Service Native App Patch"
        case "gpk":
            return "Video Service Web App Patch"
        case "gpl":
            return "PS Cloud Beta App Patch"
        case "sd":
            return "Save Data"
        default:
            return "Unknown"
        }
    }
    
    func parseSFO(inputFile: String, fullGamePath: String) -> PS4Game {
        
        let SFOReaderOutput = runSFOParser(fileInput: inputFile).output
        
        var SFOGameTitle = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "TITLE=".lowercased())
            return stringMatch != nil ? true : false
        })
        
        var SFOGameID = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "TITLE_ID=".lowercased())
            return stringMatch != nil ? true : false
        })
        
        var SFOGameVersion = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "VERSION=".lowercased())
            return stringMatch != nil ? true : false
        })
        
        var SFOGameContentID = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "CONTENT_ID=".lowercased())
            return stringMatch != nil ? true : false
        })
        
        var SFOGameType = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "CATEGORY=".lowercased())
            return stringMatch != nil ? true : false
        })
        
        var SFOGameParentalLevel = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "PARENTAL_LEVEL=".lowercased())
            return stringMatch != nil ? true : false
        })
        
        if SFOGameTitle.count == 0 {
            SFOGameTitle = ["Title: Title not found", "Title not found"]
        }
        
        if SFOGameID.count == 0 {
            SFOGameID = ["ID: Not found", "No ID"]
        }
        
        if SFOGameVersion.count == 0 {
            SFOGameVersion = ["Game Version: Not found", "No Version"]
        }
        
        if SFOGameContentID.count == 0 {
            SFOGameContentID = ["Required FW: Not found", "No FW"]
        }
        
        if SFOGameType.count == 0 {
            SFOGameType = ["Game Type: Not found", "No Type"]
        }
        else {
            if SFOGameType[0].components(separatedBy: "=")[1] == "" {
                
            }
        }
        
        if SFOGameParentalLevel.count == 0 {
            SFOGameParentalLevel = ["Parental Level: Not found", "No Level"]
        }
        
        let newGame = PS4Game(TITLE: SFOGameTitle[0].components(separatedBy: "=")[1],
                              TITLE_ID: SFOGameID[0].components(separatedBy: "=")[1],
                              VERSION: SFOGameVersion[0].components(separatedBy: "=")[1],
                              CONTENT_ID: SFOGameContentID[0].components(separatedBy: "=")[1],
                              CATEGORY: SFOGameType[0].components(separatedBy: "=")[1],
                              PARENTAL_LEVEL: SFOGameParentalLevel[0].components(separatedBy: "=")[1],
                              GAMEPATH: fullGamePath)
        
        return newGame
    }
    
    func searchGamePKG(pathURL: URL) -> [String] {
        
        var foundPKGs = [String]()
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
                if path.hasSuffix(".pkg") {
                    foundPKGs.append(path)
                }
            }
        }
        
        return foundPKGs
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return gamesList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameTitleColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "GameTitleTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].TITLE
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameIDColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "IDTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].TITLE_ID
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameVersionColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "GameVersionTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = gamesList[row].VERSION
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GamePathColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "GamePathTextField")
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
        
        loadStoreContent(ContentID: gamesList[gamesTableView.selectedRow].CONTENT_ID)
        
        GameTitleTextField.stringValue = gamesList[gamesTableView.selectedRow].TITLE
        selectedGamePath = gamesList[gamesTableView.selectedRow].GAMEPATH
        
        let correctGameID = gamesList[gamesTableView.selectedRow].TITLE_ID.components(separatedBy: CharacterSet.letters.inverted).joined() + "-" + gamesList[gamesTableView.selectedRow].TITLE_ID.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        GameIDTextField.stringValue = "Game ID: " + correctGameID
        
        ContentIDTextField.stringValue = "Content ID: " +  gamesList[gamesTableView.selectedRow].CONTENT_ID
        VersionTextField.stringValue = "Game Version: " + gamesList[gamesTableView.selectedRow].VERSION
        CategoryTextField.stringValue = "Game Type: " + ReturnCategory(shortCategory: gamesList[gamesTableView.selectedRow].CATEGORY)
        
    }
    
    
    @IBAction func LoadBackupFolder(_ sender: NSButton) {
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
            
            for foundGame in searchGamePKG(pathURL: result!)
            {
                if URL(string: foundGame)?.pathExtension == "pkg" {
                    print("PKG found: " + foundGame)
                    
                    var gamePath: String = foundGame.components(separatedBy: "file:")[1]
                    var url = URL(fileURLWithPath: gamePath)
                    
                    if gamePath.contains("%20"){
                        gamePath = gamePath.removingPercentEncoding ?? gamePath
                        url = URL(fileURLWithPath: gamePath)
                    }
                    
                    if !gamePath.contains("/PSMT/") {
                        gamesList.append(parseSFO(inputFile: gamePath, fullGamePath: url.path))
                        print(url.path)
                    }
                    
                }
                
            }
            
            gamesTableView.reloadData()
            
        } else {
            return
        }
    }
    
    @IBAction func testAction(_ sender: NSButton) {
        webVi.load(URLRequest(url: StoreURL))
    }
    
    func loadStoreContent(ContentID: String) {
        let fullURL = URL(string: "https://store.playstation.com/product/" + ContentID)
        webVi.load(URLRequest(url: fullURL!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webVi.evaluateJavaScript(BackgroundJS) { (result, error) in
            if error == nil {
                let backgroundURL = result as! String
                let bgURL = URL(string: backgroundURL)
                print("Background URL: " + backgroundURL)
                
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: bgURL!) {
                            if let image = NSImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.BackgroundImage.image = image
                                }
                            }
                    }
                }
            }
        }
        
        webVi.evaluateJavaScript(StoreDetailsJS) { (result, error) in
            if error == nil {
                let jsonData = (result as! String).data(using: .utf8)!
                let StoreVars: StorePage = try! JSONDecoder().decode(StorePage.self, from: jsonData)
                let appImageURL = URL(string: StoreVars.image)
                
                self.DescriptionTextField.stringValue = "Description: " + StoreVars.description

                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: appImageURL!) {
                            if let image = NSImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.AppImage.image = image
                                }
                            }
                    }
                }
                
            }
        }
        
    }
    
    
}

