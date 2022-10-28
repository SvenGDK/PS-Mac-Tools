//
//  MergeTableViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 14/05/2021.
//

import Cocoa
import UniformTypeIdentifiers

class MergeTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var mergeBINTable: NSTableView!
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var mergeSelectedButton: NSButton!
    @IBOutlet weak var mergeAllButton: NSButton!
    
    var cuesInList = [String]()
    let isotype = UTType(tag: "iso", tagClass: .filenameExtension, conformingTo: .compositeContent)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mergeBINTable.dataSource = self
        self.mergeBINTable.delegate = self
        self.mergeBINTable.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 1000, height: 600)
    }
    
    @IBAction func selectCue(_ sender: NSButton) {
        
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose your .cue files"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedContentTypes = [isotype]

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
    
    @IBAction func mergeSelected(_ sender: NSButton) {
        
        var game:String  = ""
        
        let alert = NSAlert()
        alert.messageText = "Please enter a new filename for the Game"
        alert.informativeText = cuesInList[mergeBINTable.selectedRow]
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 30))
        inputTextField.placeholderString = "New Title"
        alert.accessoryView = inputTextField
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            game = inputTextField.stringValue
            mergeBin(args: [cuesInList[mergeBINTable.selectedRow],game])
        }
        
    }
    
    @IBAction func mergeAll(_ sender: NSButton) {
        
        var gameTitle:String  = ""
        
        for (gameIndex, game) in cuesInList.enumerated() {
            
            let alert = NSAlert()
            alert.messageText = "Please enter a new filename for the Game"
            alert.informativeText = game
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Abort")
            
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            inputTextField.placeholderString = "New Title"
            alert.accessoryView = inputTextField
 
            if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            {
                gameTitle = inputTextField.stringValue
                mergeBin(args: [cuesInList[gameIndex], gameTitle])
            }
        }
        
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
    
    @IBAction func removeSelected(_ sender: NSButton) {
        let selectedRow =  mergeBINTable.row(for: sender)
        cuesInList.remove(at: selectedRow)
        mergeBINTable.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
    }
    
}
