//
//  BINMergeViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 05/11/2022.
//

import Cocoa
import UniformTypeIdentifiers

class BINMergePS1ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    @IBOutlet weak var mergeBINTable: NSTableView!
    
    
    var cuesInList = [String]()
    let cuetype = UTType(tag: "cue", tagClass: .filenameExtension, conformingTo: .data)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mergeBINTable.dataSource = self
        self.mergeBINTable.delegate = self
        self.mergeBINTable.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1150, height: 750)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
            return self.cuesInList.count
        }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            var result:NSTableCellView
            result  = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
            result.textField?.stringValue = self.cuesInList[row]
            return result
    }
    
    @IBAction func selectCueFiles(_ sender: NSButton) {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose your .cue files"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedContentTypes = [cuetype]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let results = dialog.urls
            
            for result in results {
                cuesInList.append(result.path)
                mergeBINTable.reloadData()
                print(result.path)
            }
        } else {
            return
        }
    }
    
    
    @IBAction func mergeAllBackups(_ sender: NSButton) {
        var gameTitle:String  = ""
        
        for (gameIndex, game) in cuesInList.enumerated() {
            
            let alert = NSAlert()
            alert.messageText = "Please enter a new filename for the Game"
            alert.informativeText = game
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Abort")
            
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            alert.accessoryView = inputTextField
 
            if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                gameTitle = inputTextField.stringValue
                mergeBin(args: [cuesInList[gameIndex], gameTitle])
            }
        }
    }
    
    @IBAction func removeCue(_ sender: NSButton) {
        let selectedRow =  mergeBINTable.row(for: sender)
        cuesInList.remove(at: selectedRow)
        mergeBINTable.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
    }    
    
    func mergeBin(args:[String])
    {
        let task = Process()
        let executableURL = Bundle.main.url(forResource: "binmerge", withExtension: "")
        task.executableURL = executableURL
        task.currentDirectoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        task.arguments = args

        task.terminationHandler = {
            _ in
            print("process run complete.")
        }

        try! task.run()
        task.waitUntilExit()

        print("execution complete...")
    }
    
}
