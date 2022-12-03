//
//  BackupManagerPSPViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa


class BackupManagerPSPViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    @IBOutlet weak var GameTItleTextField: NSTextField!
    @IBOutlet weak var GameDescriptionTextField: NSScrollView!
    @IBOutlet weak var gamesTableView: NSTableView!
    @IBOutlet weak var gameImageView: NSImageView!
    @IBOutlet weak var gameBackgroundImageView: NSImageView!
    
    
    struct PSPGame {
        var TITLE: String
        var GAMEID: String
        var VERSION: String
        var REQUIREDFW: String
        var TYPE: String
        var GAMEPATH: String
    }
    
    var currentGamesPath: String = ""
    var selectedGamePath: String = ""
    var gamesList = [PSPGame]()
    var backgroundAudioPlayer: Process = Process()
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        gamesTableView.reloadData()
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 960, height: 500)
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
    
    func parseSFO(inputFile: String, fullGamePath: String) -> PSPGame {
        
        let SFOReaderOutput = runSFOParser(fileInput: inputFile).output

        var SFOgameTitle = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "TITLE=".lowercased())
             return stringMatch != nil ? true : false
        })

        var SFOgameID = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "DISC_ID=".lowercased())
             return stringMatch != nil ? true : false
        })
        
        var SFOgameVersion = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "APP_VER=".lowercased())
             return stringMatch != nil ? true : false
        })
        
        var SFOgameReqFW = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "PSP_SYSTEM_VER=".lowercased())
             return stringMatch != nil ? true : false
        })
        
        var SFOgameType = SFOReaderOutput.filter({(item: String) -> Bool in
            let stringMatch = item.lowercased().range(of: "CATEGORY=".lowercased())
             return stringMatch != nil ? true : false
        })
        
        if SFOgameTitle.count == 0 {
            SFOgameTitle = ["Title=Not found", "Title not found"]
        }
        
        if SFOgameID.count == 0 {
            SFOgameID = ["ID=Not found", "No ID"]
        }
        
        if SFOgameVersion.count == 0 {
            SFOgameVersion = ["Game Version=Not found", "No Version"]
        }
        
        if SFOgameReqFW.count == 0 {
            SFOgameReqFW = ["Required FW=Not found", "No FW"]
        }
        
        if SFOgameType.count == 0 {
            SFOgameType = ["Game Type=Not found", "No Type"]
        }
        
        let newGame = PSPGame(TITLE: SFOgameTitle[0].components(separatedBy: "=")[1],
                              GAMEID: SFOgameID[0].components(separatedBy: "=")[1],
                              VERSION: SFOgameVersion[0].components(separatedBy: "=")[1],
                              REQUIREDFW: SFOgameReqFW[0].components(separatedBy: "=")[1],
                              TYPE: SFOgameType[0].components(separatedBy: "=")[1],
                              GAMEPATH: fullGamePath)
        
        return newGame
        
    }
    
    func searchGameSFOorISO(pathURL: URL) -> [String] {
        
            var foundSFOs = [String]()
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
                    if path.hasSuffix(".SFO") || path.hasSuffix(".iso") {
                        foundSFOs.append(path)
                    }
                }
            }

            return foundSFOs
        
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
    
    func extractFilesfromISO(filePath: String, backupDirectory: String) {
        
        let newurl = URL(string: filePath)!.path
        let unAr = Bundle.main.path(forResource: "unar", ofType: "")

        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "'" + unAr! + "' -o '" +
                            backupDirectory +
                            "/PSMT' '" + newurl +
                            "' PSP_GAME/PARAM.SFO PARAM.SFO PSP_GAME/ICON0.PNG ICON0.PNG PSP_GAME/PIC1.PNG PIC1.PNG PSP_GAME/SND0.AT3 SND0.AT3"]

        let outpipe = Pipe()
        task.standardOutput = outpipe

        task.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outdata, as: UTF8.self)

        task.waitUntilExit()
        
        print(output)
        
        let GameFolderName = URL(string: filePath)!.deletingPathExtension().lastPathComponent
        let currentGameSFO = backupDirectory + "/PSMT/" + GameFolderName + "/PSP_GAME/PARAM.SFO"
        
        gamesList.append(parseSFO(inputFile: currentGameSFO, fullGamePath: URL(string: filePath)!.path))
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return gamesList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
         
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameIDColumn") {
         
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "IDTextField")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = gamesList[row].GAMEID
                return cellView
            }
            else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameTitleColumn") {
         
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TitleTextField")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = gamesList[row].TITLE
                return cellView
            }
            else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GameVersionColumn") {
         
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "VersionTextField")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = gamesList[row].VERSION
                return cellView
            }
            else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "GamePathColumn") {
         
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "PathTextField")
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
        
        GameTItleTextField.stringValue = gamesList[gamesTableView.selectedRow].TITLE
        selectedGamePath = gamesList[gamesTableView.selectedRow].GAMEPATH
        
        //let correctGameID = gamesList[gamesTableView.selectedRow].GAMEID.components(separatedBy: CharacterSet.letters.inverted).joined() + "-" + gamesList[gamesTableView.selectedRow].GAMEID.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        //titleIDTextField.stringValue = "ID: " + correctGameID
        
        //requiredFWTextField.stringValue = "Required FW: " +  gamesList[gamesTableView.selectedRow].REQUIREDFW.replacingOccurrences(of: "0", with: "")
        //appVersionTextField.stringValue = "Game Version: " + gamesList[gamesTableView.selectedRow].VERSION
        //gameFormatTextField.stringValue = "Game Type: " + gamesList[gamesTableView.selectedRow].TYPE
        
        if !gamesList[gamesTableView.selectedRow].GAMEPATH.contains(".iso") {
        
            if fileExistsAtPath(gamesList[gamesTableView.selectedRow].GAMEPATH + "/PSP_GAME/ICON0.PNG") {
                    gameImageView.image = NSImage(byReferencingFile: gamesList[gamesTableView.selectedRow].GAMEPATH + "/PSP_GAME/ICON0.PNG")
                }
                else {
                    gameImageView.image = nil
            }
                    
                if fileExistsAtPath(gamesList[gamesTableView.selectedRow].GAMEPATH + "/PSP_GAME/PIC1.PNG") {
                    gameBackgroundImageView.image = NSImage(byReferencingFile: gamesList[gamesTableView.selectedRow].GAMEPATH + "/PS3_GAME/PIC1.PNG")
                }
                else {
                    gameBackgroundImageView.image = nil
            }
            
            if fileExistsAtPath(gamesList[gamesTableView.selectedRow].GAMEPATH + "/PSP_GAME/SND0.AT3") {
                    let ffPlay = Bundle.main.path(forResource: "ffplay", ofType: "")
                    backgroundAudioPlayer.launchPath = "/bin/sh"
                    backgroundAudioPlayer.arguments = ["-c", "'" + ffPlay! + "' -nodisp -autoexit '" + gamesList[gamesTableView.selectedRow].GAMEPATH + "/PSP_GAME/SND0.AT3'"]
                    backgroundAudioPlayer.launch()
            }
            else if fileExistsAtPath(gamesList[gamesTableView.selectedRow].GAMEPATH + "/SND0.AT3") {
                    let ffPlay = Bundle.main.path(forResource: "ffplay", ofType: "")
                    backgroundAudioPlayer.launchPath = "/bin/sh"
                    backgroundAudioPlayer.arguments = ["-c", "'" + ffPlay! + "' -nodisp -autoexit '" + gamesList[gamesTableView.selectedRow].GAMEPATH + "/SND0.AT3'"]
                    backgroundAudioPlayer.launch()
            }
            
        }
        else {
            
            let selectedGameISO = URL(fileURLWithPath: gamesList[gamesTableView.selectedRow].GAMEPATH)
            let gameCacheFolder = selectedGameISO.deletingLastPathComponent().path + "/PSMT/"
            let selectedGameName = selectedGameISO.deletingPathExtension().lastPathComponent
                 
            if fileExistsAtPath(gameCacheFolder + selectedGameName + "/PSP_GAME/ICON0.PNG") {
                    gameImageView.image = NSImage(byReferencingFile: gameCacheFolder + selectedGameName + "/PSP_GAME/ICON0.PNG")
                }
                else {
                    gameImageView.image = nil
            }
                    
                if fileExistsAtPath(gameCacheFolder + selectedGameName + "/PSP_GAME/PIC1.PNG") {
                    gameBackgroundImageView.image = NSImage(byReferencingFile: gameCacheFolder + selectedGameName + "/PSP_GAME/PIC1.PNG")
                }
                else {
                    gameBackgroundImageView.image = nil
            }
            
            if fileExistsAtPath(gameCacheFolder + selectedGameName + "/PSP_GAME/SND0.AT3") {
                let ffPlay = Bundle.main.path(forResource: "ffplay", ofType: "")
                backgroundAudioPlayer.launchPath = "/bin/sh"
                backgroundAudioPlayer.arguments = ["-c", "'" + ffPlay! + "' -nodisp -autoexit '" + gameCacheFolder + selectedGameName + "/PSP_GAME/SND0.AT3'"]
                backgroundAudioPlayer.launch()
            }
            else if fileExistsAtPath(gameCacheFolder + selectedGameName + "/SND0.AT3") {
                let ffPlay = Bundle.main.path(forResource: "ffplay", ofType: "")
                backgroundAudioPlayer.launchPath = "/bin/sh"
                backgroundAudioPlayer.arguments = ["-c", "'" + ffPlay! + "' -nodisp -autoexit '" + gameCacheFolder + selectedGameName + "/SND0.AT3'"]
                backgroundAudioPlayer.launch()
            }
            
        }
        
    }
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        if backgroundAudioPlayer.isRunning {
            print("STILL RUNNING - Killing...")
            backgroundAudioPlayer.terminate()
            backgroundAudioPlayer = Process()
        }
        else {
            print("NOT RUNNING")
        }
    }
    
    override func viewWillDisappear() {
        if backgroundAudioPlayer.isRunning {
            print("AUDIO RUNNING - Killing...")
            backgroundAudioPlayer.terminate()
            backgroundAudioPlayer = Process()
        }
    }
    
    
    
    @IBAction func LoadBackupFolder(_ sender: NSButton) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose your games folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            gamesList.removeAll()
            let result = dialog.url
            currentGamesPath = result!.path
            
            for foundGame in searchGameSFOorISO(pathURL: result!)
            {
                if URL(string: foundGame)?.pathExtension == "iso" {
 
                    let gamePath: String = foundGame.components(separatedBy: "file:")[1]
                    let gameFolderName = URL(string: gamePath)!.deletingPathExtension().lastPathComponent

                    if directoryExistsAtPath(currentGamesPath + "/PSMT/" + gameFolderName) {
                        print("ISO already extracted: " + URL(string: gamePath)!.path)
                        gamesList.append(parseSFO(inputFile: currentGamesPath + "/PSMT/" + gameFolderName + "/PSP_GAME/PARAM.SFO", fullGamePath: URL(string: gamePath)!.path))
                    }
                    else
                    {
                        print("Extracting ISO: " + URL(string: gamePath)!.path)
                        extractFilesfromISO(filePath: gamePath, backupDirectory: currentGamesPath)
                    }
                    
                }
                else {
                    print("Game Folder found:")

                    var gamePath: String = ""
                    gamePath = foundGame.components(separatedBy: "file:")[1]
                    
                    var url = URL(fileURLWithPath: gamePath)
                    var dirUrl = url.deletingLastPathComponent().deletingLastPathComponent()
                    
                    if gamePath.contains("%20"){
                        gamePath = gamePath.removingPercentEncoding ?? gamePath
                        url = URL(fileURLWithPath: gamePath)
                        dirUrl = url.deletingLastPathComponent().deletingLastPathComponent()
                    }
                    
                    if !gamePath.contains("/PSMT/") {
                        gamesList.append(parseSFO(inputFile: gamePath, fullGamePath: dirUrl.path))
                        print(dirUrl.path)
                    }
                }
                
            }
            gamesTableView.reloadData()
            
        } else {
            return
        }
    }
}
