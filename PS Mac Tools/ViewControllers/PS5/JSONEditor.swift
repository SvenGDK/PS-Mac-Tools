//
//  JSONEditor.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 04/12/2023.
//

import Cocoa
import UniformTypeIdentifiers

class JSONEditor: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var ParametersTableView: NSTableView!
    @IBOutlet weak var AvailableParametersComboBox: NSComboBox!
    @IBOutlet weak var NewParameterValueTextField: NSTextField!
    @IBOutlet weak var ModifyParameterTextField: NSTextField!
    @IBOutlet weak var AddNewParameterButton: NSButton!
    @IBOutlet weak var SaveModifiedParameterButton: NSButton!
    @IBOutlet weak var RemoveParameterButton: NSButton!
    @IBOutlet weak var OpenAdvancedEditorButton: NSButton!
    @IBOutlet weak var SaveModificationsButton: NSButton!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        ParametersTableView.delegate = self
        ParametersTableView.dataSource = self
        ParametersTableView.reloadData()
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
            preferredContentSize = NSSize(width: 1300, height: 800)
    }
    
    let param_parameters:[String] = ["ageLevel",
                               "applicationCategoryType",
                               "applicationDrmType",
                               "attribute","attribute2","attribute3",
                               "contentBadgeType",
                               "contentId",
                               "contentVersion",
                               "deeplinkUri",
                               "downloadDataSize",
                               "localizedParameters",
                               "masterVersion",
                               "requiredSystemSoftwareVersion",
                               "titleId",
                               "versionFileUri"]
    
    let manifest_parameters:[String] = ["applicationName",
                                        "applicationVersion",
                                        "commitHash",
                                        "bootAnimation",
                                        "titleId",
                                        "reactNativePlaystationVersion",
                                        "applicationData",
                                        "twinTurbo"]
    
    struct ParamTableItem {
        var ParameterName: String
        var ParameterValue: String
        var ParameterType: String
    }
    
    var SelectedParamJSON: PS5Param!
    var SelectedParamJSONPath: String = ""
    
    var SelectedManifestJSON: PS5Manifest!
    var SelectedManifestJSONPath: String = ""
    
    var ParamTableItems = [ParamTableItem]()
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "ParameterColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ParameterTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = ParamTableItems[row].ParameterName
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "ValueColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ValueTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = ParamTableItems[row].ParameterValue
            return cellView
        }
        else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "TypeColumn") {
     
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ParamTypeTextField")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = ParamTableItems[row].ParameterType
            return cellView
        }
        else
        {
            return nil
        }
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if !ParametersTableView.selectedRowIndexes.isEmpty {
            
            SaveModifiedParameterButton.isEnabled = true
            RemoveParameterButton.isEnabled = true
            
            if ParamTableItems[ParametersTableView.selectedRow].ParameterValue == "Open in advanced Editor" {
                OpenAdvancedEditorButton.isEnabled = true
            }
            else {
                OpenAdvancedEditorButton.isEnabled = false
                ModifyParameterTextField.stringValue = ParamTableItems[ParametersTableView.selectedRow].ParameterValue
            }
        } else {
            SaveModifiedParameterButton.isEnabled = false
            RemoveParameterButton.isEnabled = false
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ParamTableItems.count
    }
    
    func AddAvailableParamParameters() {
        AvailableParametersComboBox.removeAllItems()
        AvailableParametersComboBox.addItems(withObjectValues: param_parameters)
    }
    
    func AddAvailableManifestParameters() {
        AvailableParametersComboBox.removeAllItems()
        AvailableParametersComboBox.addItems(withObjectValues: manifest_parameters)
    }
    
    func AddParamJSONParameters() {
        
        if SelectedParamJSON.addcont != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "addcont", ParameterValue: "Open in advanced Editor", ParameterType: "List (String)")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if !SelectedParamJSON.ageLevel!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "ageLevel", ParameterValue: "Open in advanced Editor", ParameterType: "Dict (String, Integer)")
            ParamTableItems.append(NewParamTableItem)
        }
        
        switch SelectedParamJSON.applicationCategoryType {
        case 0:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "0", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 65792:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "65792", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 131328:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "131328", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 131584:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "131584", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 16777216:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "16777216", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 33554432:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "33554432", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 67108864:
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: "67108864", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        default:
            print("No valid applicationCategoryType")
        }

        if !SelectedParamJSON.applicationDRMType!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationDrmType", ParameterValue: SelectedParamJSON.applicationDRMType!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        switch SelectedParamJSON.attribute {
        case 0:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: "0", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 1:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: "1", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 536870912:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: "536870912", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 1073741824:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: "1073741824", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 1107296256:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: "1107296256", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 1644167168:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: "1644167168", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        default:
            print("No valid attribute")
        }
        
        switch SelectedParamJSON.attribute2 {
        case 0:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute2", ParameterValue: "0", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 4:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute2", ParameterValue: "4", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        default:
            print("No valid attribute2")
        }
        
        switch SelectedParamJSON.attribute3 {
        case 0:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: "0", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 4:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: "4", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 68:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: "68", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 80:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: "80", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 132:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: "132", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 4160:
            let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: "4160", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        default:
            print("No valid attribute3")
        }
        
        if !SelectedParamJSON.conceptID!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "conceptId", ParameterValue: SelectedParamJSON.conceptID!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        switch SelectedParamJSON.contentBadgeType {
        case 0:
            let NewParamTableItem = ParamTableItem(ParameterName: "contentBadgeType", ParameterValue: "0", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 1:
            let NewParamTableItem = ParamTableItem(ParameterName: "contentBadgeType", ParameterValue: "1", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        case 2:
            let NewParamTableItem = ParamTableItem(ParameterName: "contentBadgeType", ParameterValue: "2", ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        default:
            print("No valid attribute2")
        }
        
        if !SelectedParamJSON.contentID!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "contentId", ParameterValue: SelectedParamJSON.contentID!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if !SelectedParamJSON.contentVersion!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "contentVersion", ParameterValue: SelectedParamJSON.contentVersion!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.deeplinkUri != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "deeplinkUri", ParameterValue: SelectedParamJSON.deeplinkUri!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.downloadDataSize != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "downloadDataSize", ParameterValue: String(SelectedParamJSON.downloadDataSize!), ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.gameIntent != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "gameIntent", ParameterValue: "Open in advanced Editor", ParameterType: "Dict(intentType, String)")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if !SelectedParamJSON.localizedParameters!.defaultLanguage!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "localizedParameters", ParameterValue: "Open in advanced Editor", ParameterType: "Dict(languageIdentifer, titleName)")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if !SelectedParamJSON.masterVersion!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "masterVersion", ParameterValue: SelectedParamJSON.masterVersion!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.pubtools != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "pubtools", ParameterValue: "Open in advanced Editor", ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.requiredSystemSoftwareVersion != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "requiredSystemSoftwareVersion", ParameterValue: SelectedParamJSON.requiredSystemSoftwareVersion!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.savedata != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "savedata", ParameterValue: "Open in advanced Editor", ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.sdkVersion != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "sdkVersion", ParameterValue: SelectedParamJSON.sdkVersion!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if !SelectedParamJSON.titleID!.isEmpty {
            let NewParamTableItem = ParamTableItem(ParameterName: "titleId", ParameterValue: SelectedParamJSON.titleID!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.userDefinedParam1 != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "userDefinedParam1", ParameterValue: String(SelectedParamJSON.userDefinedParam1!), ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.userDefinedParam2 != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "userDefinedParam2", ParameterValue: String(SelectedParamJSON.userDefinedParam2!), ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.userDefinedParam3 != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "userDefinedParam3", ParameterValue: String(SelectedParamJSON.userDefinedParam3!), ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedParamJSON.userDefinedParam4 != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "userDefinedParam4", ParameterValue: String(SelectedParamJSON.userDefinedParam4!), ParameterType: "Integer")
            ParamTableItems.append(NewParamTableItem)
        }
    
        if SelectedParamJSON.versionFileURI != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "versionFileUri", ParameterValue: SelectedParamJSON.versionFileURI!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }

        ParametersTableView.reloadData()
    }
    
    func AddManifestJSONParameters() {
        
        if SelectedManifestJSON.applicationName != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationName", ParameterValue: SelectedManifestJSON.applicationName!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.applicationVersion != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationVersion", ParameterValue: SelectedManifestJSON.applicationVersion!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.commitHash != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "commitHash", ParameterValue: SelectedManifestJSON.commitHash!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.bootAnimation != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "bootAnimation", ParameterValue: SelectedManifestJSON.bootAnimation!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.titleID != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "titleID", ParameterValue: SelectedManifestJSON.titleID!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.reactNativePlaystationVersion != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "reactNativePlaystationVersion", ParameterValue: SelectedManifestJSON.reactNativePlaystationVersion!, ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.applicationData != nil {
            let NewParamTableItem = ParamTableItem(ParameterName: "applicationData", ParameterValue: "Open in advanced Editor", ParameterType: "String")
            ParamTableItems.append(NewParamTableItem)
        }
        
        if SelectedManifestJSON.twinTurbo != nil {
            if SelectedManifestJSON.twinTurbo == true {
                let NewParamTableItem = ParamTableItem(ParameterName: "twinTurbo", ParameterValue: "true", ParameterType: "Boolean")
                ParamTableItems.append(NewParamTableItem)
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "twinTurbo", ParameterValue: "false", ParameterType: "Boolean")
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        ParametersTableView.reloadData()
    }
    
    @IBAction func LoadJSONFile(_ sender: NSButton) {
        
        let dialog = NSOpenPanel()

        dialog.title = "Choose your .json file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [UTType.json]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            
            let result = dialog.url
            
            ParamTableItems.removeAll()
            
            do {
                let jsonfiledata = try Data(contentsOf: result!)
                let decoder = JSONDecoder()
                        
                if result!.lastPathComponent == "param.json" {
                    SelectedParamJSON = try decoder.decode(PS5Param.self, from: jsonfiledata)
                    SelectedParamJSONPath = result!.path
                    
                    SelectedManifestJSON = nil
                    AddParamJSONParameters()
                    AddAvailableParamParameters()
                    AddNewParameterButton.isEnabled = true
                }
                else if result!.lastPathComponent == "manifest.json" {
                    SelectedManifestJSON = try decoder.decode(PS5Manifest.self, from: jsonfiledata)
                    SelectedManifestJSONPath = result!.path
                    
                    SelectedParamJSON = nil
                    AddManifestJSONParameters()
                    AddAvailableManifestParameters()
                    AddNewParameterButton.isEnabled = true
                }
                else {
                    print("No valid JSON file.")
                }
                        
            } catch {
                print("Error decoding JSON:\(error)")
            }

        }
    
    }
    
    @IBAction func AddParameter(_ sender: NSButton) {
        
        //Notify if parameter already exists
        for param in ParamTableItems {
            if param.ParameterName == AvailableParametersComboBox.stringValue {
                let AlreadyExistsAlert = NSAlert()
                AlreadyExistsAlert.messageText = "Parameter already exists."
                AlreadyExistsAlert.runModal()
                break
            }
        }
        
        let NewParameterValue: String = NewParameterValueTextField.stringValue
        let BadValueAlert = NSAlert()
        BadValueAlert.messageText = "Param/Manifest Editor"
        BadValueAlert.addButton(withTitle: "Close")
        
        //Add parameter
        if AvailableParametersComboBox.stringValue == "ageLevel" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "ageLevel", ParameterValue: "Open in advanced Editor", ParameterType: "Dict (String, Integer)")
                SelectedParamJSON.ageLevel = ["default" : Int(NewParameterValue) ?? 0]
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "applicationCategoryType" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "applicationCategoryType", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.applicationCategoryType = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "applicationDrmType" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "applicationDrmType", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.applicationDRMType = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "attribute" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "attribute", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.attribute = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "attribute2" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "attribute2", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.attribute2 = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "attribute3" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "attribute3", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.attribute3 = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "contentBadgeType" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "contentBadgeType", ParameterValue: NewParameterValue.description, ParameterType: "Integer")
                SelectedParamJSON.contentBadgeType = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "contentId" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "contentId", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.contentID = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "contentVersion" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "contentVersion", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.contentVersion = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "deeplinkUri" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "deeplinkUri", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.deeplinkUri = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "downloadDataSize" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "downloadDataSize", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.downloadDataSize = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableParametersComboBox.stringValue == "localizedParameters" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "localizedParameters", ParameterValue: "Open in advanced Editor", ParameterType: "Dict(languageIdentifer, titleName)")
                SelectedParamJSON.localizedParameters!.defaultLanguage = "enUS"
                SelectedParamJSON.localizedParameters!.enUS!.titleName = "Title Name"
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "masterVersion" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "masterVersion", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.masterVersion = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "requiredSystemSoftwareVersion" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "requiredSystemSoftwareVersion", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.requiredSystemSoftwareVersion = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "titleId" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "titleId", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.titleID = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableParametersComboBox.stringValue == "versionFileUri" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "versionFileUri", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.versionFileURI = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        ParametersTableView.reloadData()
    }
    
    @IBAction func OpenHelp(_ sender: NSButton) {
        if let PS5DevWikiURL = URL(string: "https://www.psdevwiki.com/ps5/Param.json") {
            NSWorkspace.shared.open(PS5DevWikiURL)
        }
    }
    
    @IBAction func SaveParameter(_ sender: NSButton) {
        
        if !ParametersTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = ParametersTableView.selectedRow
            let SelectedItem: ParamTableItem = ParamTableItems[SelectedRow]
            let NewParameterValue: String = ModifyParameterTextField.stringValue
                        
            let BadValueAlert = NSAlert()
            BadValueAlert.messageText = "Param/Manifest Editor"
            BadValueAlert.addButton(withTitle: "Close")
            
            switch SelectedItem.ParameterName {
            case "applicationName":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedManifestJSON.applicationName = NewParameterValue
                }
            case "applicationVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedManifestJSON.applicationVersion = NewParameterValue
                }
            case "commitHash":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedManifestJSON.commitHash = NewParameterValue
                }
            case "bootAnimation":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedManifestJSON.bootAnimation = NewParameterValue
                }
            case "titleId":
                if SelectedParamJSON == nil {
                    if NewParameterValue.isNumber {
                        BadValueAlert.informativeText = "Only String values allowed."
                        BadValueAlert.runModal()
                    } else {
                        ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                        SelectedManifestJSON.titleID = NewParameterValue
                    }
                } else {
                    if NewParameterValue.isNumber {
                        BadValueAlert.informativeText = "Only String values allowed."
                        BadValueAlert.runModal()
                    } else {
                        ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                        SelectedParamJSON.titleID = NewParameterValue
                    }
                }
            case "reactNativePlaystationVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedManifestJSON.reactNativePlaystationVersion = NewParameterValue
                }
            case "twinTurbo":
                if NewParameterValue == "true" || NewParameterValue == "false" {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    if NewParameterValue == "true" {
                        SelectedManifestJSON.twinTurbo = true
                    } else {
                        SelectedManifestJSON.twinTurbo = false
                    }
                } else {
                    BadValueAlert.informativeText = "Only true OR false allowed."
                    BadValueAlert.runModal()
                }
            case "applicationCategoryType":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.applicationCategoryType = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "applicationDrmType":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.applicationDRMType = NewParameterValue
                }
            case "attribute":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.attribute = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "attribute2":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.attribute2 = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "attribute3":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.attribute3 = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "conceptId":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.conceptID = NewParameterValue
                }
            case "contentBadgeType":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.contentBadgeType = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "contentId":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.contentID = NewParameterValue
                }
            case "contentVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.contentVersion = NewParameterValue
                }
            case "downloadDataSize":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.downloadDataSize = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "masterVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.masterVersion = NewParameterValue
                }
            case "requiredSystemSoftwareVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.requiredSystemSoftwareVersion = NewParameterValue
                }
            case "sdkVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.sdkVersion = NewParameterValue
                }
            case "userDefinedParam1":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.userDefinedParam1 = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "userDefinedParam2":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.userDefinedParam2 = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "userDefinedParam3":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.userDefinedParam3 = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "userDefinedParam4":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.userDefinedParam4 = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "versionFileUri":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.versionFileURI = NewParameterValue
                }
            default:
                BadValueAlert.informativeText = "No Parameter selected."
                BadValueAlert.runModal()
            }
            
            SaveModificationsButton.isEnabled = true
            ParametersTableView.reloadData()
        }
        
    }
    
    @IBAction func RemoveParameter(_ sender: NSButton) {
        
        if !ParametersTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = ParametersTableView.selectedRow
            let SelectedItem: ParamTableItem = ParamTableItems[SelectedRow]
            
            let RemovedAlert = NSAlert()
            RemovedAlert.messageText = "Param/Manifest Editor"
            RemovedAlert.addButton(withTitle: "Close")
            
            switch SelectedItem.ParameterName {
            case "applicationName":
                SelectedManifestJSON.applicationName = nil
            case "applicationVersion":
                SelectedManifestJSON.applicationVersion = nil
            case "commitHash":
                SelectedManifestJSON.commitHash = nil
            case "bootAnimation":
                SelectedManifestJSON.bootAnimation = nil
            case "titleId":
                if SelectedParamJSON == nil {
                    SelectedManifestJSON.titleID = nil
                } else {
                    SelectedParamJSON.titleID = nil
                }
            case "reactNativePlaystationVersion":
                SelectedManifestJSON.reactNativePlaystationVersion = nil
            case "twinTurbo":
                SelectedManifestJSON.twinTurbo = false
            case "addcont":
                SelectedParamJSON.addcont = nil
            case "ageLevel":
                SelectedParamJSON.ageLevel = nil
            case "applicationCategoryType":
                SelectedParamJSON.applicationCategoryType = nil
            case "applicationDrmType":
                SelectedParamJSON.applicationDRMType = nil
            case "attribute":
                SelectedParamJSON.attribute = nil
            case "attribute2":
                SelectedParamJSON.attribute2 = nil
            case "attribute3":
                SelectedParamJSON.attribute3 = nil
            case "conceptId":
                SelectedParamJSON.conceptID = nil
            case "contentBadgeType":
                SelectedParamJSON.contentBadgeType = nil
            case "contentId":
                SelectedParamJSON.contentID = nil
            case "contentVersion":
                SelectedParamJSON.applicationDRMType = nil
            case "downloadDataSize":
                SelectedParamJSON.downloadDataSize = nil
            case "gameIntent":
                SelectedParamJSON.gameIntent = nil
            case "kernel":
                SelectedParamJSON.kernel = nil
            case "masterVersion":
                SelectedParamJSON.masterVersion = nil
            case "localizedParameters":
                SelectedParamJSON.localizedParameters = nil
            case "pubtools":
                SelectedParamJSON.pubtools = nil
            case "requiredSystemSoftwareVersion":
                SelectedParamJSON.requiredSystemSoftwareVersion = nil
            case "sdkVersion":
                SelectedParamJSON.sdkVersion = nil
            case "userDefinedParam1":
                SelectedParamJSON.userDefinedParam1 = nil
            case "userDefinedParam2":
                SelectedParamJSON.userDefinedParam2 = nil
            case "userDefinedParam3":
                SelectedParamJSON.userDefinedParam3 = nil
            case "userDefinedParam4":
                SelectedParamJSON.userDefinedParam4 = nil
            case "versionFileUri":
                SelectedParamJSON.versionFileURI = nil
            default:
                RemovedAlert.informativeText = "No Parameter selected."
                RemovedAlert.runModal()
            }
            
            ParamTableItems.remove(at: SelectedRow)
            ParametersTableView.reloadData()
            SaveModificationsButton.isEnabled = true
            
            RemovedAlert.informativeText = "Parameter deleted from param.json"
            RemovedAlert.runModal()
        }
        
    }
    
    @IBAction func CreateNewParamJSON(_ sender: NSButton) {
        let NewParamJSON = PS5Param(ageLevel: ["default" : 0],
                                    applicationCategoryType: 0,
                                    applicationDRMType: "standard",
                                    attribute: 0,
                                    attribute2: 0,
                                    attribute3: 0,
                                    conceptID: "99999",
                                    contentBadgeType: 0,
                                    contentID: "IV9999-CUSA99999_00-XXXXXXXXXXXXXXXX",
                                    contentVersion: "01.000.000",
                                    downloadDataSize: 0,
                                    localizedParameters: LocalizedParameters(defaultLanguage: "en-US",enUS: EnUS(titleName: "Title Name")),
                                    masterVersion: "01.00",
                                    requiredSystemSoftwareVersion: "0x0114000000000000",
                                    titleID: "CUSA99999")
        
        ParamTableItems.removeAll()
        
        SelectedManifestJSON = nil
        SelectedParamJSON = NewParamJSON
        AddParamJSONParameters()
        AddAvailableParamParameters()
        AddNewParameterButton.isEnabled = true
    }
    
    @IBAction func CreateNewManifestJSON(_ sender: NSButton) {
        let NewManifestJSON = PS5Manifest(applicationName: "Title Name",
                                          applicationVersion: "0.0.0+000",
                                          commitHash: "",
                                          bootAnimation: "default",
                                          titleID: "NPXS00000",
                                          reactNativePlaystationVersion: "0.00.0-000.0",
                                          applicationData: ApplicationData(branchType: "release"),
                                          twinTurbo: true)
        
        ParamTableItems.removeAll()
        
        SelectedParamJSON = nil
        SelectedManifestJSON = NewManifestJSON
        AddManifestJSONParameters()
        AddAvailableManifestParameters()
        AddNewParameterButton.isEnabled = true
    }
    
    @IBAction func SaveJSONFile(_ sender: NSButton) {
        
        let SaveDialog = NSSavePanel()
        SaveDialog.showsResizeIndicator = true
        SaveDialog.showsHiddenFiles = false
        SaveDialog.allowedContentTypes = [UTType.json]
        SaveDialog.canCreateDirectories = true
        
        if SelectedParamJSON == nil {
            do {
                let ManifestParameters = SelectedManifestJSON
                let NewEncoder = JSONEncoder()
                NewEncoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
                let JSONData = try NewEncoder.encode(ManifestParameters)
         
                SaveDialog.title = "Save manifest.json"
                if (SaveDialog.runModal() ==  NSApplication.ModalResponse.OK) {
                    let result = SaveDialog.url
                    if result!.isFileURL == true {
                        try JSONData.write(to: result!)
                    }
                }
                
            } catch {
                print(error)
            }
        } else {
            do {
                let ParamParameters = SelectedParamJSON
                let NewEncoder = JSONEncoder()
                NewEncoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
                let JSONData = try NewEncoder.encode(ParamParameters)
                
                SaveDialog.title = "Save param.json"
                if (SaveDialog.runModal() ==  NSApplication.ModalResponse.OK) {
                    let result = SaveDialog.url
                    if result!.isFileURL == true {
                        try JSONData.write(to: result!)
                    }
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    func ReceiveJSON(with ParamJSON: PS5Param?, with ManifestJSON: PS5Manifest?) {
        if ParamJSON != nil {
            self.SelectedParamJSON = ParamJSON
            SaveModificationsButton.isEnabled = true
        } else if ManifestJSON != nil {
            self.SelectedManifestJSON = ManifestJSON
            SaveModificationsButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenAdvancedEditor" {
            
            let AdvancedEditorWindow = segue.destinationController as! AdvancedJSONEditor
            
            if !ParametersTableView.selectedRowIndexes.isEmpty {
                
                let SelectedRow: Int = ParametersTableView.selectedRow
                let SelectedItem: ParamTableItem = ParamTableItems[SelectedRow]
                
                if SelectedParamJSON == nil {
                    AdvancedEditorWindow.SelectedManifestJSON = SelectedManifestJSON
                } else {
                    AdvancedEditorWindow.SelectedParamJSON = SelectedParamJSON
                }
                
                AdvancedEditorWindow.delegate = self
                        
                switch SelectedItem.ParameterName {
                case "addcont":
                    AdvancedEditorWindow.ParameterName = "addcont"
                    
                    //Not supported yet
                    print("")
                case "ageLevel":
                    AdvancedEditorWindow.ParameterName = "ageLevel"
                    
                    if SelectedParamJSON.ageLevel!["AE"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "AE", ParameterValue: SelectedParamJSON.ageLevel!["AE"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["AR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "AR", ParameterValue: SelectedParamJSON.ageLevel!["AR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["AU"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "AU", ParameterValue: SelectedParamJSON.ageLevel!["AU"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["BE"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "BE", ParameterValue: SelectedParamJSON.ageLevel!["BE"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["BG"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "BG", ParameterValue: SelectedParamJSON.ageLevel!["BG"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["BH"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "BH", ParameterValue: SelectedParamJSON.ageLevel!["BH"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["BO"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "BO", ParameterValue: SelectedParamJSON.ageLevel!["BO"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["BR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "BR", ParameterValue: SelectedParamJSON.ageLevel!["BR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CA"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CA", ParameterValue: SelectedParamJSON.ageLevel!["CA"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CH"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CH", ParameterValue: SelectedParamJSON.ageLevel!["CH"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CL"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CL", ParameterValue: SelectedParamJSON.ageLevel!["CL"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CN"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CN", ParameterValue: SelectedParamJSON.ageLevel!["CN"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CO"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CO", ParameterValue: SelectedParamJSON.ageLevel!["CO"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CR", ParameterValue: SelectedParamJSON.ageLevel!["CR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CY"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CY", ParameterValue: SelectedParamJSON.ageLevel!["CY"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["CZ"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "CZ", ParameterValue: SelectedParamJSON.ageLevel!["CZ"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["DE"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "DE", ParameterValue: SelectedParamJSON.ageLevel!["DE"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["DK"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "DK", ParameterValue: SelectedParamJSON.ageLevel!["DK"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["EC"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "EC", ParameterValue: SelectedParamJSON.ageLevel!["EC"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["ES"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ES", ParameterValue: SelectedParamJSON.ageLevel!["ES"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["FI"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "FI", ParameterValue: SelectedParamJSON.ageLevel!["FI"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["FR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "FR", ParameterValue: SelectedParamJSON.ageLevel!["FR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["GB"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "GB", ParameterValue: SelectedParamJSON.ageLevel!["GB"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["GR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "GR", ParameterValue: SelectedParamJSON.ageLevel!["GR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["GT"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "GT", ParameterValue: SelectedParamJSON.ageLevel!["GT"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["HK"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "HK", ParameterValue: SelectedParamJSON.ageLevel!["HK"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["HN"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "HN", ParameterValue: SelectedParamJSON.ageLevel!["HN"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["HR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "HR", ParameterValue: SelectedParamJSON.ageLevel!["HR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["HU"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "HU", ParameterValue: SelectedParamJSON.ageLevel!["HU"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["ID"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ID", ParameterValue: SelectedParamJSON.ageLevel!["ID"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["IE"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "IE", ParameterValue: SelectedParamJSON.ageLevel!["IE"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["IL"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "IL", ParameterValue: SelectedParamJSON.ageLevel!["IL"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["IN"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "IN", ParameterValue: SelectedParamJSON.ageLevel!["IN"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["IS"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "IS", ParameterValue: SelectedParamJSON.ageLevel!["IS"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["IT"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "IT", ParameterValue: SelectedParamJSON.ageLevel!["IT"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["JP"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "JP", ParameterValue: SelectedParamJSON.ageLevel!["JP"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["KR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "KR", ParameterValue: SelectedParamJSON.ageLevel!["KR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["KW"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "KW", ParameterValue: SelectedParamJSON.ageLevel!["KW"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["LB"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "LB", ParameterValue: SelectedParamJSON.ageLevel!["LB"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["LU"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "LU", ParameterValue: SelectedParamJSON.ageLevel!["LU"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["MT"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "MT", ParameterValue: SelectedParamJSON.ageLevel!["MT"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["MX"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "MX", ParameterValue: SelectedParamJSON.ageLevel!["MX"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["MY"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "MY", ParameterValue: SelectedParamJSON.ageLevel!["MY"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["NI"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "NI", ParameterValue: SelectedParamJSON.ageLevel!["NI"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["NL"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "NL", ParameterValue: SelectedParamJSON.ageLevel!["NL"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["NO"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "NO", ParameterValue: SelectedParamJSON.ageLevel!["NO"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["NZ"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "NZ", ParameterValue: SelectedParamJSON.ageLevel!["NZ"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["OM"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "OM", ParameterValue: SelectedParamJSON.ageLevel!["OM"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["PA"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "PA", ParameterValue: SelectedParamJSON.ageLevel!["PA"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["PE"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "PE", ParameterValue: SelectedParamJSON.ageLevel!["PE"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["PL"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "PL", ParameterValue: SelectedParamJSON.ageLevel!["PL"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["PT"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "PT", ParameterValue: SelectedParamJSON.ageLevel!["PT"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["PY"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "PY", ParameterValue: SelectedParamJSON.ageLevel!["PY"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["QA"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "QA", ParameterValue: SelectedParamJSON.ageLevel!["QA"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["RO"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "RO", ParameterValue: SelectedParamJSON.ageLevel!["RO"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["RU"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "RU", ParameterValue: SelectedParamJSON.ageLevel!["RU"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["SA"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "SA", ParameterValue: SelectedParamJSON.ageLevel!["SA"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["SE"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "SE", ParameterValue: SelectedParamJSON.ageLevel!["SE"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["SG"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "SG", ParameterValue: SelectedParamJSON.ageLevel!["SG"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["SI"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "SI", ParameterValue: SelectedParamJSON.ageLevel!["SI"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["SK"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "SK", ParameterValue: SelectedParamJSON.ageLevel!["SK"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["SV"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "SV", ParameterValue: SelectedParamJSON.ageLevel!["SV"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["TH"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "TH", ParameterValue: SelectedParamJSON.ageLevel!["TH"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["TR"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "TR", ParameterValue: SelectedParamJSON.ageLevel!["TR"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["TW"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "TW", ParameterValue: SelectedParamJSON.ageLevel!["TW"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["UA"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "UA", ParameterValue: SelectedParamJSON.ageLevel!["UA"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["US"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "US", ParameterValue: SelectedParamJSON.ageLevel!["US"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["UY"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "UY", ParameterValue: SelectedParamJSON.ageLevel!["UY"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["ZA"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ZA", ParameterValue: SelectedParamJSON.ageLevel!["ZA"]!.description, ParameterType: "Integer"))
                    }
                    if SelectedParamJSON.ageLevel!["default"] != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "default", ParameterValue: SelectedParamJSON.ageLevel!["default"]!.description, ParameterType: "Integer"))
                    }
                case "applicationData":
                    AdvancedEditorWindow.ParameterName = "applicationData"
                    
                    if SelectedManifestJSON.applicationData != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "branchType", ParameterValue: SelectedManifestJSON.applicationData!.branchType!, ParameterType: "String"))
                    }
                case "gameIntent":
                    AdvancedEditorWindow.ParameterName = "gameIntent"
                    
                    //Not supported yet
                    print("")
                case "kernel":
                    AdvancedEditorWindow.ParameterName = "kernel"
                    
                    if SelectedParamJSON.kernel != nil {
                        if SelectedParamJSON.kernel?.cpuPageTableSize != nil {
                            AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "cpuPageTableSize", ParameterValue: SelectedParamJSON.kernel!.cpuPageTableSize!.description, ParameterType: "Integer"))
                        }
                        if SelectedParamJSON.kernel?.flexibleMemorySize != nil {
                            AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "flexibleMemorySize", ParameterValue: SelectedParamJSON.kernel!.flexibleMemorySize!.description, ParameterType: "Integer"))
                        }
                        if SelectedParamJSON.kernel?.gpuPageTableSize != nil {
                            AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "gpuPageTableSize", ParameterValue: SelectedParamJSON.kernel!.gpuPageTableSize!.description, ParameterType: "Integer"))
                        }
                    }
                case "localizedParameters":
                    AdvancedEditorWindow.ParameterName = "localizedParameters"
                    
                    AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "defaultLanguage", ParameterValue: SelectedParamJSON.localizedParameters!.defaultLanguage!, ParameterType: "String"))
                    AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "en-US", ParameterValue: SelectedParamJSON.localizedParameters!.enUS!.titleName!, ParameterType: "String"))
                    
                    if SelectedParamJSON.localizedParameters!.arAE != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ar-AE", ParameterValue: SelectedParamJSON.localizedParameters!.arAE!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.csCZ != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "cs-CZ", ParameterValue: SelectedParamJSON.localizedParameters!.csCZ!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.daDK != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "da-DK", ParameterValue: SelectedParamJSON.localizedParameters!.daDK!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.deDE != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "de-DE", ParameterValue: SelectedParamJSON.localizedParameters!.deDE!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.elGR != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "el-GR", ParameterValue: SelectedParamJSON.localizedParameters!.elGR!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.enGB != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "en-GB", ParameterValue: SelectedParamJSON.localizedParameters!.enGB!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.es419 != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "es-419", ParameterValue: SelectedParamJSON.localizedParameters!.es419!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.esES != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "es-ES", ParameterValue: SelectedParamJSON.localizedParameters!.esES!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.fiFI != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "fi-FI", ParameterValue: SelectedParamJSON.localizedParameters!.fiFI!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.frCA != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "fr-CA", ParameterValue: SelectedParamJSON.localizedParameters!.frCA!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.frFR != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "fr-FR", ParameterValue: SelectedParamJSON.localizedParameters!.frFR!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.huHU != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "hu-HU", ParameterValue: SelectedParamJSON.localizedParameters!.huHU!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.idID != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "id-ID", ParameterValue: SelectedParamJSON.localizedParameters!.idID!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.itIT != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "it-IT", ParameterValue: SelectedParamJSON.localizedParameters!.itIT!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.jaJP != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ja-JP", ParameterValue: SelectedParamJSON.localizedParameters!.jaJP!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.koKR != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ko-KR", ParameterValue: SelectedParamJSON.localizedParameters!.koKR!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.nlNL != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "nl-NL", ParameterValue: SelectedParamJSON.localizedParameters!.nlNL!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.noNO != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "no-NO", ParameterValue: SelectedParamJSON.localizedParameters!.noNO!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.plPL != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "pl-PL", ParameterValue: SelectedParamJSON.localizedParameters!.plPL!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.ptBR != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "pt-BR", ParameterValue: SelectedParamJSON.localizedParameters!.ptBR!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.ptPT != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "pt-PT", ParameterValue: SelectedParamJSON.localizedParameters!.ptPT!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.roRO != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ro-RO", ParameterValue: SelectedParamJSON.localizedParameters!.roRO!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.ruRU != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "ru-RU", ParameterValue: SelectedParamJSON.localizedParameters!.ruRU!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.svSE != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "sv-SE", ParameterValue: SelectedParamJSON.localizedParameters!.svSE!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.thTH != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "th-TH", ParameterValue: SelectedParamJSON.localizedParameters!.thTH!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.trTR != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "tr-TR", ParameterValue: SelectedParamJSON.localizedParameters!.trTR!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.viVN != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "vi-VN", ParameterValue: SelectedParamJSON.localizedParameters!.viVN!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.zhHans != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "zh-Hans", ParameterValue: SelectedParamJSON.localizedParameters!.zhHans!.titleName!, ParameterType: "String"))
                    }
                    if SelectedParamJSON.localizedParameters!.zhHant != nil {
                        AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "zh-Hant", ParameterValue: SelectedParamJSON.localizedParameters!.zhHant!.titleName!, ParameterType: "String"))
                    }
                case "pubtools":
                    AdvancedEditorWindow.ParameterName = "pubtools"
                    
                    if SelectedParamJSON.pubtools != nil {
                        if SelectedParamJSON.pubtools?.creationDate != nil {
                            AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "creationDate", ParameterValue: SelectedParamJSON.pubtools!.creationDate!, ParameterType: "String"))
                        }
                        if SelectedParamJSON.pubtools?.loudnessSnd0 != nil {
                            AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "loudnessSnd0", ParameterValue: SelectedParamJSON.pubtools!.loudnessSnd0!, ParameterType: "String"))
                        }
                        if SelectedParamJSON.pubtools?.submission != nil {
                            if SelectedParamJSON.pubtools?.submission == true {
                                AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "submission", ParameterValue: "true", ParameterType: "Boolean"))
                            } else {
                                AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "submission", ParameterValue: "false", ParameterType: "Boolean"))
                            }
                        }
                        if SelectedParamJSON.pubtools?.toolVersion != nil {
                            AdvancedEditorWindow.ParamTableItems.append(AdvancedJSONEditor.ParamTableItem(ParameterName: "toolVersion", ParameterValue: SelectedParamJSON.pubtools!.toolVersion!, ParameterType: "String"))
                        }
                    }
                default:
                    print("No valid parameter selected.")
                }

            }
        
        }
    }
    
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
