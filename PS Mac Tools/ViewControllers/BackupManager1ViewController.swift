//
//  BackupManager1ViewController.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 27/10/2022.
//

import Cocoa

class BackupManager1ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 1200, height: 750)
    }
    
}
