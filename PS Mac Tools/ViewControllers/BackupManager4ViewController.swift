//
//  BackupManager4ViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 27/10/2022.
//

import Cocoa

class BackupManager4ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    @IBOutlet weak var gamesTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        gamesTableView.reloadData()
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 1200, height: 750)
    }
    
}
