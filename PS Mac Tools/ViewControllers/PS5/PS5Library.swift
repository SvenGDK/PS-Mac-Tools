//
//  PS5Library.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 11/12/2023.
//

import Cocoa

class PS5Library: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    @IBOutlet weak var GamesTableView: NSTableView!
    @IBOutlet weak var AppsTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        GamesTableView.delegate = self
        GamesTableView.dataSource = self
        GamesTableView.reloadData()
        
        AppsTableView.delegate = self
        AppsTableView.dataSource = self
        AppsTableView.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    struct GameOrApp {
        var GameAppPath: String?
        var GameAppTitle: String?
        var GameAppID: String?
        var GameAppRegion: String?
        var GameAppContentID: String?
        var GameAppSize: String?
        var GameAppVersion: String?
        var GameAppRequiredFirmware: String?
    }
    
    var GamesList = [GameOrApp]()
    var AppsList = [GameOrApp]()
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "GamesTableView") {
            return GamesList.count
        }
        else if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "AppsTableView") {
            return AppsList.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "GameTableCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? GameTableCellView else { return nil }
            
            cellView.GameTitleTextField.stringValue = GamesList[row].GameAppTitle!
            cellView.GameIDTextField.stringValue = GamesList[row].GameAppID!
            cellView.GameRegionTextField.stringValue = GamesList[row].GameAppRegion!
            cellView.GameContentIDTextField.stringValue = GamesList[row].GameAppContentID!
            cellView.GameSizeTextField.stringValue = GamesList[row].GameAppSize!
            cellView.GameVersionTextField.stringValue = GamesList[row].GameAppVersion!
            cellView.GameRequiredFirmwareTextField.stringValue = GamesList[row].GameAppRequiredFirmware!
            
            if FileManager.default.fileExists(atPath: GamesList[row].GameAppPath! + "sce_sys/icon0.png") {
                cellView.GameIconImageView.image = NSImage(byReferencingFile: GamesList[row].GameAppPath! + "/sce_sys/icon0.png")
            }
            
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "AppsColumn") {
            
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "AppTableCellView")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? AppTableCellView else { return nil }
            
            cellView.AppTitleTextField.stringValue = AppsList[row].GameAppTitle!
            cellView.AppIDTextField.stringValue = AppsList[row].GameAppID!
            cellView.AppRegionTextField.stringValue = AppsList[row].GameAppRegion!
            cellView.AppContentIDTextField.stringValue = AppsList[row].GameAppContentID!
            cellView.AppSizeTextField.stringValue = AppsList[row].GameAppSize!
            cellView.AppVersionTextField.stringValue = AppsList[row].GameAppVersion!
            cellView.AppRequiredFirmwareTextField.stringValue = AppsList[row].GameAppRequiredFirmware!
            
            if FileManager.default.fileExists(atPath: AppsList[row].GameAppPath! + "sce_sys/icon0.png") {
                cellView.AppIconImageView.image = NSImage(byReferencingFile: AppsList[row].GameAppPath! + "/sce_sys/icon0.png")
            }
            
            return cellView
        }
        else
        {
            return nil
        }
    }
    
    func GameAppRegion(GameID: String) -> String {
        if GameID.starts(with: "PPSA") {
            return "NA / Europe"
        }
        else if GameID.starts(with: "ECAS") {
            return "Asia"
        }
        else if GameID.starts(with: "ELAS") {
            return "Asia"
        }
        else if GameID.starts(with: "ELJM") {
            return "Japan"
        }
        else {
            return ""
        }
    }
    
    func ReadableRequiredFirmware(RequiredFW: String) -> String {
        var GameOrAppRequiredFirmware: String = RequiredFW.replacingOccurrences(of: "0x", with: "")
        GameOrAppRequiredFirmware.insert(".", at: GameOrAppRequiredFirmware.index(GameOrAppRequiredFirmware.startIndex, offsetBy: 2))
        GameOrAppRequiredFirmware.insert(".", at: GameOrAppRequiredFirmware.index(GameOrAppRequiredFirmware.startIndex, offsetBy: 5))
        GameOrAppRequiredFirmware.insert(".", at: GameOrAppRequiredFirmware.index(GameOrAppRequiredFirmware.startIndex, offsetBy: 8))
        GameOrAppRequiredFirmware.remove(at: GameOrAppRequiredFirmware.index(GameOrAppRequiredFirmware.startIndex, offsetBy: 11))
        
        let EndRange = GameOrAppRequiredFirmware.index(GameOrAppRequiredFirmware.endIndex, offsetBy: -7)..<GameOrAppRequiredFirmware.endIndex
        GameOrAppRequiredFirmware.removeSubrange(EndRange)
        
        return GameOrAppRequiredFirmware
    }
    
    func ParseParamJson(ParamJSONFile: URL) -> GameOrApp {
        
        var GameDirectoryPath: String = ParamJSONFile.deletingLastPathComponent().deletingLastPathComponent().absoluteString.components(separatedBy: "file://")[1]
        var GameDirectoryURL = URL(fileURLWithPath: GameDirectoryPath)
        if GameDirectoryPath.contains("%20"){
            GameDirectoryPath = GameDirectoryPath.removingPercentEncoding ?? GameDirectoryPath
            GameDirectoryURL = URL(fileURLWithPath: GameDirectoryPath)
        }
        
        //Get the game directory size
        var GameDirectorySize: String = ""
        do {
            if let sizeOnDisk = try GameDirectoryURL.sizeOnDisk() {
                GameDirectorySize = sizeOnDisk
            }
        } catch {
            GameDirectorySize = "0.0 GB on disk"
        }

        //Parse param.json for game information
        do {
            let jsonfiledata = try Data(contentsOf: ParamJSONFile)
            let decoder = JSONDecoder()
            let decodedParam = try decoder.decode(PS5Param.self, from: jsonfiledata)
            let GameOrAppRegion: String = GameAppRegion(GameID: decodedParam.titleID!)
            var GameOrAppReqFirmware: String = "Unknown"
            
            if decodedParam.requiredSystemSoftwareVersion != nil {
                GameOrAppReqFirmware = ReadableRequiredFirmware(RequiredFW: decodedParam.requiredSystemSoftwareVersion!)
            }
            
            let NewGameOrApp: GameOrApp = GameOrApp(GameAppPath: GameDirectoryPath,
                                                    GameAppTitle: decodedParam.localizedParameters!.enUS!.titleName!,
                                                    GameAppID: decodedParam.titleID,
                                                    GameAppRegion: GameOrAppRegion,
                                                    GameAppContentID: decodedParam.contentID,
                                                    GameAppSize: GameDirectorySize,
                                                    GameAppVersion: "Version: " + decodedParam.contentVersion!,
                                                    GameAppRequiredFirmware: "Requires Firmware: " + GameOrAppReqFirmware)
            return NewGameOrApp
        } catch {
            print(error)
            return GameOrApp()
        }
        
    }
    
    func SearchForParamJSON(BackupPath: URL) -> [URL] {
        var FoundParamJSONs = [URL]()
        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]

        let enumerator = fileManager.enumerator(
                at: BackupPath,
                includingPropertiesForKeys: keys,
                options: options,
                errorHandler: {(url, error) -> Bool in
                    return true
        })

        if enumerator != nil {
            while let file = enumerator!.nextObject() {
                let path = file as! URL
                if path.absoluteString.hasSuffix("param.json") {
                    FoundParamJSONs.append(path)
                    }
                }
        }

        return FoundParamJSONs
    }
    
    @IBAction func LoadGamesAndApps(_ sender: NSButton) {
        
        let FolderBrowserDialog = NSOpenPanel()

        FolderBrowserDialog.title = "Select your backup folder"
        FolderBrowserDialog.showsResizeIndicator = true
        FolderBrowserDialog.showsHiddenFiles = false
        FolderBrowserDialog.canChooseFiles = false
        FolderBrowserDialog.canChooseDirectories = true
        FolderBrowserDialog.allowsMultipleSelection = false

        if (FolderBrowserDialog.runModal() ==  NSApplication.ModalResponse.OK) {
            
            let SelectedFolderURL: URL = FolderBrowserDialog.url!
            for FoundGameOrApp in SearchForParamJSON(BackupPath: SelectedFolderURL)
            {
                let ParsedGameAppInfo: GameOrApp = ParseParamJson(ParamJSONFile: FoundGameOrApp)
                if ParsedGameAppInfo.GameAppID != nil {
                    if ParsedGameAppInfo.GameAppID!.starts(with: "PP") == true {
                        GamesList.append(ParsedGameAppInfo)
                    }
                    else {
                        AppsList.append(ParsedGameAppInfo)
                    }
                }
            }
            
            GamesTableView.reloadData()
            AppsTableView.reloadData()
        }
        
    }
    
}

extension URL {
    
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }

    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                    (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
                 (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                    .totalFileAllocatedSize ?? 0) + $0
        }
    }

    func sizeOnDisk() throws -> String? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil}
        return byteCount + " on disk"
    }
    private static let byteCountFormatter = ByteCountFormatter()
}
