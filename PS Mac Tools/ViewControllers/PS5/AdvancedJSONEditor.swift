//
//  AdvancedJSONEditor.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 16/12/2023.
//

import Cocoa

class AdvancedJSONEditor: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var AdvancedParametersTableView: NSTableView!
    @IBOutlet weak var ParameterNameTextField: NSTextField!
    @IBOutlet weak var AvailableAdvancedParamatersComboBox: NSComboBox!
    @IBOutlet weak var NewParameterValueTextField: NSTextField!
    @IBOutlet weak var AddNewParameterButton: NSButton!
    @IBOutlet weak var ModifyParameterValueTextField: NSTextField!
    @IBOutlet weak var SaveParameterButton: NSButton!
    @IBOutlet weak var RemoveParameterButton: NSButton!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        AdvancedParametersTableView.delegate = self
        AdvancedParametersTableView.dataSource = self
        
        //Set title showing which parameter gets modified
        ParameterNameTextField.stringValue = "Modifying '" + ParameterName + "'"
        
        //Add available sub parameters to the ComboBox
        switch ParameterName {
        case "addcont":
            AddAvailableParamParameters(Parameters: ["serviceIdForSharing"])
        case "ageLevel":
            AddAvailableParamParameters(Parameters: ["AE", "AR", "AT", "AU", "BE", "BG", "BH", "BO", "BR", "CA",
                                                     "CH", "CL", "CN", "CO", "CR", "CY", "CZ", "DE", "DK", "EC",
                                                     "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HR", "HU",
                                                     "ID", "IE", "IL", "IN", "IS", "IT", "JP", "KR", "KW", "LB",
                                                     "LU", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "OM", "PA",
                                                     "PE", "PL", "PT", "PY", "QA", "RO", "RU", "SA", "SE", "SG",
                                                     "SI", "SK", "SV", "TH", "TR", "TW", "UA", "US", "UY", "ZA",
                                                     "default"])
        case "applicationData":
            AddAvailableParamParameters(Parameters: ["branchType"])
        case "gameIntent":
            AddAvailableParamParameters(Parameters: ["permittedIntents"])
        case "kernel":
            AddAvailableParamParameters(Parameters: ["cpuPageTableSize", "flexibleMemorySize", "gpuPageTableSize"])
        case "localizedParameters":
            AddAvailableParamParameters(Parameters: ["ar-AE", "cs-CZ", "da-DK", "de-DE", "defaultLanguage", "el-GR",
                                                     "en-GB", "en-US", "es-419", "es-ES", "fi-FI", "fr-CA", "fr-FR",
                                                     "hu-HU", "id-ID", "it-IT", "ja-JP", "ko-KR", "nl-NL", "no-NO",
                                                     "pl-PL", "pt-BR", "pt-PT", "ro-RO", "ru-RU", "sv-SE", "th-TH",
                                                     "tr-TR", "vi-VN", "zh-Hans", "zh-Hant"])
        case "pubtools":
            AddAvailableParamParameters(Parameters: ["creationDate", "loudnessSnd0", "submission", "toolVersion"])
        default:
            AddAvailableParamParameters(Parameters: [""])
        }
    }
    
    override func viewWillAppear() {
            super.viewWillAppear()
    }
    
    var delegate: JSONEditor? //Used to return the modifications to the main JSON Editor
    let advanced_manifest_parameters:[String] = ["branchType"]
    
    struct ParamTableItem {
        var ParameterName: String
        var ParameterValue: String
        var ParameterType: String
    }
    
    var ParameterName: String = ""
    var SelectedParamJSON: PS5Param!
    var SelectedManifestJSON: PS5Manifest!
    
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
        if !AdvancedParametersTableView.selectedRowIndexes.isEmpty {
            SaveParameterButton.isEnabled = true
            RemoveParameterButton.isEnabled = true
            ModifyParameterValueTextField.stringValue = ParamTableItems[AdvancedParametersTableView.selectedRow].ParameterValue
        } else {
            SaveParameterButton.isEnabled = false
            RemoveParameterButton.isEnabled = false
            ModifyParameterValueTextField.stringValue = ""
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ParamTableItems.count
    }
    
    func AddAvailableParamParameters(Parameters: [String]) {
        AvailableAdvancedParamatersComboBox.removeAllItems()
        AvailableAdvancedParamatersComboBox.addItems(withObjectValues: Parameters)
    }
    
    func AddAvailableManifestParameters() {
        AvailableAdvancedParamatersComboBox.removeAllItems()
        AvailableAdvancedParamatersComboBox.addItems(withObjectValues: advanced_manifest_parameters)
    }
    
    @IBAction func RemoveAdvancedParameter(_ sender: NSButton) {
        if !AdvancedParametersTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = AdvancedParametersTableView.selectedRow
            let SelectedItem: ParamTableItem = ParamTableItems[SelectedRow]
            
            let RemovedAlert = NSAlert()
            RemovedAlert.messageText = "Param/Manifest Editor"
            RemovedAlert.addButton(withTitle: "Close")
            
            switch SelectedItem.ParameterName {
            case "serviceIdForSharing":
                SelectedParamJSON.addcont?.serviceIDForSharing = nil
            case "AE":
                SelectedParamJSON.ageLevel?["AE"] = nil
            case "AR":
                SelectedParamJSON.ageLevel?["AR"] = nil
            case "AT":
                SelectedParamJSON.ageLevel?["AT"] = nil
            case "AU":
                SelectedParamJSON.ageLevel?["AU"] = nil
            case "BE":
                SelectedParamJSON.ageLevel?["BE"] = nil
            case "BG":
                SelectedParamJSON.ageLevel?["BG"] = nil
            case "BH":
                SelectedParamJSON.ageLevel?["BH"] = nil
            case "BO":
                SelectedParamJSON.ageLevel?["BO"] = nil
            case "BR":
                SelectedParamJSON.ageLevel?["BR"] = nil
            case "CA":
                SelectedParamJSON.ageLevel?["CA"] = nil
            case "CH":
                SelectedParamJSON.ageLevel?["CH"] = nil
            case "CL":
                SelectedParamJSON.ageLevel?["CL"] = nil
            case "CN":
                SelectedParamJSON.ageLevel?["CN"] = nil
            case "CO":
                SelectedParamJSON.ageLevel?["CO"] = nil
            case "CR":
                SelectedParamJSON.ageLevel?["CR"] = nil
            case "CY":
                SelectedParamJSON.ageLevel?["CY"] = nil
            case "CZ":
                SelectedParamJSON.ageLevel?["CZ"] = nil
            case "DE":
                SelectedParamJSON.ageLevel?["DE"] = nil
            case "DK":
                SelectedParamJSON.ageLevel?["DK"] = nil
            case "EC":
                SelectedParamJSON.ageLevel?["EC"] = nil
            case "ES":
                SelectedParamJSON.ageLevel?["ES"] = nil
            case "FI":
                SelectedParamJSON.ageLevel?["FI"] = nil
            case "FR":
                SelectedParamJSON.ageLevel?["FR"] = nil
            case "GB":
                SelectedParamJSON.ageLevel?["GB"] = nil
            case "GR":
                SelectedParamJSON.ageLevel?["GR"] = nil
            case "GT":
                SelectedParamJSON.ageLevel?["GT"] = nil
            case "HK":
                SelectedParamJSON.ageLevel?["HK"] = nil
            case "HN":
                SelectedParamJSON.ageLevel?["HN"] = nil
            case "HR":
                SelectedParamJSON.ageLevel?["HR"] = nil
            case "HU":
                SelectedParamJSON.ageLevel?["HU"] = nil
            case "ID":
                SelectedParamJSON.ageLevel?["ID"] = nil
            case "IE":
                SelectedParamJSON.ageLevel?["IE"] = nil
            case "IL":
                SelectedParamJSON.ageLevel?["IL"] = nil
            case "IN":
                SelectedParamJSON.ageLevel?["IN"] = nil
            case "IS":
                SelectedParamJSON.ageLevel?["IS"] = nil
            case "IT":
                SelectedParamJSON.ageLevel?["IT"] = nil
            case "JP":
                SelectedParamJSON.ageLevel?["JP"] = nil
            case "KR":
                SelectedParamJSON.ageLevel?["KR"] = nil
            case "KW":
                SelectedParamJSON.ageLevel?["KW"] = nil
            case "LB":
                SelectedParamJSON.ageLevel?["LB"] = nil
            case "LU":
                SelectedParamJSON.ageLevel?["LU"] = nil
            case "MT":
                SelectedParamJSON.ageLevel?["MT"] = nil
            case "MX":
                SelectedParamJSON.ageLevel?["MX"] = nil
            case "MY":
                SelectedParamJSON.ageLevel?["MY"] = nil
            case "NI":
                SelectedParamJSON.ageLevel?["NI"] = nil
            case "NL":
                SelectedParamJSON.ageLevel?["NL"] = nil
            case "NO":
                SelectedParamJSON.ageLevel?["NO"] = nil
            case "NZ":
                SelectedParamJSON.ageLevel?["NZ"] = nil
            case "OM":
                SelectedParamJSON.ageLevel?["OM"] = nil
            case "PA":
                SelectedParamJSON.ageLevel?["PA"] = nil
            case "PE":
                SelectedParamJSON.ageLevel?["PE"] = nil
            case "PL":
                SelectedParamJSON.ageLevel?["PL"] = nil
            case "PT":
                SelectedParamJSON.ageLevel?["PT"] = nil
            case "PY":
                SelectedParamJSON.ageLevel?["PY"] = nil
            case "QA":
                SelectedParamJSON.ageLevel?["QA"] = nil
            case "RO":
                SelectedParamJSON.ageLevel?["RO"] = nil
            case "RU":
                SelectedParamJSON.ageLevel?["RU"] = nil
            case "SA":
                SelectedParamJSON.ageLevel?["SA"] = nil
            case "SE":
                SelectedParamJSON.ageLevel?["SE"] = nil
            case "SG":
                SelectedParamJSON.ageLevel?["SG"] = nil
            case "SI":
                SelectedParamJSON.ageLevel?["SI"] = nil
            case "SK":
                SelectedParamJSON.ageLevel?["SK"] = nil
            case "SV":
                SelectedParamJSON.ageLevel?["SV"] = nil
            case "TH":
                SelectedParamJSON.ageLevel?["TH"] = nil
            case "TR":
                SelectedParamJSON.ageLevel?["TR"] = nil
            case "TW":
                SelectedParamJSON.ageLevel?["TW"] = nil
            case "UA":
                SelectedParamJSON.ageLevel?["UA"] = nil
            case "US":
                SelectedParamJSON.ageLevel?["US"] = nil
            case "UY":
                SelectedParamJSON.ageLevel?["UY"] = nil
            case "ZA":
                SelectedParamJSON.ageLevel?["ZA"] = nil
            case "default":
                SelectedParamJSON.ageLevel?["default"] = nil
            case "branchType":
                SelectedManifestJSON.applicationData?.branchType = nil
            case "permittedIntents":
                SelectedParamJSON.gameIntent?.permittedIntents = nil
            case "cpuPageTableSize":
                SelectedParamJSON.kernel?.cpuPageTableSize = nil
            case "flexibleMemorySize":
                SelectedParamJSON.kernel?.flexibleMemorySize = nil
            case "gpuPageTableSize":
                SelectedParamJSON.kernel?.gpuPageTableSize = nil
            case "ar-AE":
                SelectedParamJSON.localizedParameters?.arAE = nil
            case "cs-CZ":
                SelectedParamJSON.localizedParameters?.csCZ = nil
            case "da-DK":
                SelectedParamJSON.localizedParameters?.daDK = nil
            case "de-DE":
                SelectedParamJSON.localizedParameters?.deDE = nil
            case "defaultLanguage":
                SelectedParamJSON.localizedParameters?.defaultLanguage = nil
            case "el-GR":
                SelectedParamJSON.localizedParameters?.elGR = nil
            case "en-GB":
                SelectedParamJSON.localizedParameters?.enGB = nil
            case "en-US":
                SelectedParamJSON.localizedParameters?.enUS = nil
            case "es-419":
                SelectedParamJSON.localizedParameters?.es419 = nil
            case "es-ES":
                SelectedParamJSON.localizedParameters?.esES = nil
            case "fi-FI":
                SelectedParamJSON.localizedParameters?.fiFI = nil
            case "fr-CA":
                SelectedParamJSON.localizedParameters?.frCA = nil
            case "fr-FR":
                SelectedParamJSON.localizedParameters?.frFR = nil
            case "hu-HU":
                SelectedParamJSON.localizedParameters?.huHU = nil
            case "id-ID":
                SelectedParamJSON.localizedParameters?.idID = nil
            case "it-IT":
                SelectedParamJSON.localizedParameters?.itIT = nil
            case "ja-JP":
                SelectedParamJSON.localizedParameters?.jaJP = nil
            case "ko-KR":
                SelectedParamJSON.localizedParameters?.koKR = nil
            case "nl-NL":
                SelectedParamJSON.localizedParameters?.nlNL = nil
            case "no-NO":
                SelectedParamJSON.localizedParameters?.noNO = nil
            case "pl-PL":
                SelectedParamJSON.localizedParameters?.plPL = nil
            case "pt-BR":
                SelectedParamJSON.localizedParameters?.ptBR = nil
            case "pt-PT":
                SelectedParamJSON.localizedParameters?.ptPT = nil
            case "ro-RO":
                SelectedParamJSON.localizedParameters?.roRO = nil
            case "ru-RU":
                SelectedParamJSON.localizedParameters?.ruRU = nil
            case "sv-SE":
                SelectedParamJSON.localizedParameters?.svSE = nil
            case "th-TH":
                SelectedParamJSON.localizedParameters?.thTH = nil
            case "tr-TR":
                SelectedParamJSON.localizedParameters?.trTR = nil
            case "vi-VN":
                SelectedParamJSON.localizedParameters?.viVN = nil
            case "zh-Hans":
                SelectedParamJSON.localizedParameters?.zhHans = nil
            case "zh-Hant":
                SelectedParamJSON.localizedParameters?.zhHant = nil
            case "creationDate":
                SelectedParamJSON.pubtools?.creationDate = nil
            case "loudnessSnd0":
                SelectedParamJSON.pubtools?.loudnessSnd0 = nil
            case "submission":
                SelectedParamJSON.pubtools?.submission = nil
            case "toolVersion":
                SelectedParamJSON.pubtools?.toolVersion = nil
            default:
                RemovedAlert.informativeText = "No Parameter selected."
                RemovedAlert.runModal()
            }
            
            ParamTableItems.remove(at: SelectedRow)
            AdvancedParametersTableView.reloadData()
            
            if SelectedParamJSON == nil {
                delegate?.ReceiveJSON(with: nil, with: SelectedManifestJSON)
            } else {
                delegate?.ReceiveJSON(with: SelectedParamJSON, with: nil)
            }
            
            RemovedAlert.informativeText = "Parameter deleted."
            RemovedAlert.runModal()
        }
    }
    
    @IBAction func SaveAdvancedParameter(_ sender: NSButton) {
        if !AdvancedParametersTableView.selectedRowIndexes.isEmpty {
            
            let SelectedRow: Int = AdvancedParametersTableView.selectedRow
            let SelectedItem: ParamTableItem = ParamTableItems[SelectedRow]
            let NewParameterValue: String = ModifyParameterValueTextField.stringValue
            
            let BadValueAlert = NSAlert()
            BadValueAlert.messageText = "Param/Manifest Editor"
            BadValueAlert.addButton(withTitle: "Close")
            
            switch SelectedItem.ParameterName {
            case "AE":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!.updateValue(Int(NewParameterValue) ?? 0, forKey: "AE")
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "AR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["AR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "AT":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["AT"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "AU":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["AU"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "BE":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["BE"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "BG":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["BG"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "BH":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["BH"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "BO":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["BO"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "BR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["BR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CA":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CA"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CH":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CH"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CL":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CL"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CN":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CN"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CO":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CO"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CY":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CY"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "CZ":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["CZ"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "DE":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["DE"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "DK":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["DK"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "EC":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["EC"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "ES":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["ES"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "FI":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["FI"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "FR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["FR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "GB":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["GB"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "GR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["GR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "GT":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["GT"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "HK":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["HK"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "HN":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["HN"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "HR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["HR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "HU":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["HU"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "ID":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["ID"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "IE":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["IE"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "IL":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["IL"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "IN":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["IN"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "IS":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["IS"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "IT":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["IT"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "JP":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["JP"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "KR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["KR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "KW":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["KW"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "LB":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["LB"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "LU":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["LU"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "MT":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["MT"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "MX":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["MX"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "MY":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["MY"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "NI":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["NI"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "NL":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["NL"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "NO":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["NO"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "NZ":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["NZ"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "OM":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["OM"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "PA":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["PA"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "PE":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["PE"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "PL":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["PL"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "PT":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["PT"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "PY":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["PY"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "QA":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["QA"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "RO":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["RO"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "RU":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["RU"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "SA":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["SA"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "SE":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["SE"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "SG":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["SG"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "SI":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["SI"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "SK":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["SK"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "SV":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["SV"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "TH":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["TH"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "TR":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["TR"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "TW":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["TW"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "UA":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["UA"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "US":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["US"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "UY":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["UY"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "ZA":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["ZA"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "default":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.ageLevel!["default"] = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
                
            case "cpuPageTableSize":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.kernel!.cpuPageTableSize = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "flexibleMemorySize":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.kernel!.flexibleMemorySize = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
            case "gpuPageTableSize":
                if NewParameterValue.isNumber {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.kernel!.gpuPageTableSize = Int(NewParameterValue) ?? 0
                } else {
                    BadValueAlert.informativeText = "Only Integer values allowed."
                    BadValueAlert.runModal()
                }
                
            case "ar-AE":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.arAE!.titleName = NewParameterValue
                }
            case "cs-CZ":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.csCZ!.titleName = NewParameterValue
                }
            case "da-DK":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.daDK!.titleName = NewParameterValue
                }
            case "de-DE":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.deDE!.titleName = NewParameterValue
                }
            case "defaultLanguage":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.defaultLanguage = NewParameterValue
                }
            case "el-GR":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.elGR!.titleName = NewParameterValue
                }
            case "en-GB":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.enGB!.titleName = NewParameterValue
                }
            case "en-US":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.enUS!.titleName = NewParameterValue
                }
            case "es-419":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.es419!.titleName = NewParameterValue
                }
            case "es-ES":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                }
            case "fi-FI":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.fiFI!.titleName = NewParameterValue
                }
            case "fr-CA":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.frCA!.titleName = NewParameterValue
                }
            case "fr-FR":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.frFR!.titleName = NewParameterValue
                }
            case "hu-HU":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.huHU!.titleName = NewParameterValue
                }
            case "id-ID":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.idID!.titleName = NewParameterValue
                }
            case "it-IT":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.itIT!.titleName = NewParameterValue
                }
            case "ja-JP":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.jaJP!.titleName = NewParameterValue
                }
            case "ko-KR":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.koKR!.titleName = NewParameterValue
                }
            case "nl-NL":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.nlNL!.titleName = NewParameterValue
                }
            case "no-NO":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.noNO!.titleName = NewParameterValue
                }
            case "pl-PL":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.plPL!.titleName = NewParameterValue
                }
            case "pt-BR":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.ptBR!.titleName = NewParameterValue
                }
            case "pt-PT":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.ptPT!.titleName = NewParameterValue
                }
            case "ro-RO":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.roRO!.titleName = NewParameterValue
                }
            case "ru-RU":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.ruRU!.titleName = NewParameterValue
                }
            case "sv-SE":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.svSE!.titleName = NewParameterValue
                }
            case "th-TH":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.thTH!.titleName = NewParameterValue
                }
            case "tr-TR":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.trTR!.titleName = NewParameterValue
                }
            case "vi-VN":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.viVN!.titleName = NewParameterValue
                }
            case "zh-Hans":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.zhHans!.titleName = NewParameterValue
                }
            case "zh-Hant":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.localizedParameters!.zhHant!.titleName = NewParameterValue
                }
                
            case "creationDate":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.pubtools?.creationDate = NewParameterValue
                }
            case "loudnessSnd0":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.pubtools!.loudnessSnd0 = NewParameterValue
                }
            case "submission":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only true OR false allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    if NewParameterValue == "true" {
                        SelectedParamJSON.pubtools!.submission = true
                    } else {
                        SelectedParamJSON.pubtools!.submission = false
                    }
                }
            case "toolVersion":
                if NewParameterValue.isNumber {
                    BadValueAlert.informativeText = "Only String values allowed."
                    BadValueAlert.runModal()
                } else {
                    ParamTableItems[SelectedRow].ParameterValue = NewParameterValue
                    SelectedParamJSON.pubtools!.toolVersion = NewParameterValue
                }
                
            default:
                BadValueAlert.informativeText = "No Parameter selected."
                BadValueAlert.runModal()
            }
            
            if SelectedParamJSON == nil {
                delegate?.ReceiveJSON(with: nil, with: SelectedManifestJSON)
            } else {
                delegate?.ReceiveJSON(with: SelectedParamJSON, with: nil)
            }
            
            AdvancedParametersTableView.reloadData()
        }
    }
    
    @IBAction func AddNewAdvancedParameter(_ sender: NSButton) {
        
        //Notify if parameter already exists
        for param in ParamTableItems {
            if param.ParameterName == AvailableAdvancedParamatersComboBox.stringValue {
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
        if AvailableAdvancedParamatersComboBox.stringValue == "AE" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "AE", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["AE"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "AR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "AR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["AR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "AT" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "AT", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["AT"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "AU" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "AU", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["AU"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "BE" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "BE", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["BE"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "BG" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "BG", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["BG"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "BH" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "BH", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["BH"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "BO" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "BO", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["BO"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "BR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "BR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["BR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CA" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CA", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CA"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CH" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CH", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CH"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CL" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CL", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CL"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CN" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CN", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CN"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CO" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CO", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CO"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CY" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CY", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CY"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "CZ" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "CZ", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["CZ"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "DE" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "DE", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["DE"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "DK" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "DK", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["DK"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "EC" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "EC", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["EC"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ES" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "ES", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["ES"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "FI" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "FI", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["FI"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "FR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "FR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["FR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "GB" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "GB", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["GB"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "GR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "GR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["GR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "GT" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "GT", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["GT"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "HK" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "HK", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["HK"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "HN" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "HN", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["HN"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "HR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "HR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["HR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "HU" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "HU", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["HU"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ID" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "ID", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["ID"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "IE" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "IE", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["IE"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "IL" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "IL", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["IL"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "IN" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "IN", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["IN"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "IS" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "IS", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["IS"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "IT" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "IT", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["IT"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "JP" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "JP", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["JP"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "KR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "KR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["KR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "KW" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "KW", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["KW"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "LB" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "LB", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["LB"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "LU" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "LU", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["LU"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "MT" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "MT", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["MT"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "MX" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "MX", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["MX"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "MY" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "MY", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["MY"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "NI" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "NI", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["NI"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "NL" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "NL", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["NL"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "NO" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "NO", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["NO"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "NZ" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "NZ", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["NZ"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "OM" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "OM", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["OM"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "PA" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "PA", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["PA"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "PE" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "PE", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["PE"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "PL" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "PL", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["PL"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "PT" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "PT", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["PT"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "PY" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "PY", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["PY"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "QA" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "QA", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["QA"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "RO" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "RO", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["RO"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "RU" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "RU", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["RU"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "SA" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "SA", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["SA"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "SE" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "SE", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["SE"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "SG" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "SG", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["SG"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "SI" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "SI", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["SI"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "SK" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "SK", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["SK"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "SV" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "SV", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["SV"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "TH" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "TH", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["TH"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "TR" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "TR", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["TR"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "TW" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "TW", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["TW"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "UA" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "UA", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["UA"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "US" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "US", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["US"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "UY" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "UY", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["UY"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ZA" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "ZA", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["ZA"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "default" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "default", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.ageLevel!["default"] = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "branchType" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "branchType", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedManifestJSON.applicationData!.branchType = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "cpuPageTableSize" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "cpuPageTableSize", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.kernel!.cpuPageTableSize = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "flexibleMemorySize" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "flexibleMemorySize", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.kernel!.flexibleMemorySize = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "gpuPageTableSize" {
            if NewParameterValue.isNumber {
                let NewParamTableItem = ParamTableItem(ParameterName: "gpuPageTableSize", ParameterValue: NewParameterValue, ParameterType: "Integer")
                SelectedParamJSON.kernel!.gpuPageTableSize = Int(NewParameterValue) ?? 0
                ParamTableItems.append(NewParamTableItem)
            } else {
                BadValueAlert.informativeText = "Only Integer values allowed."
                BadValueAlert.runModal()
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ar-AE" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "ar-AE", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.arAE!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "cs-CZ" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "cs-CZ", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.csCZ!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "da-DK" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "da-DK", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.daDK!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "de-DE" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "de-DE", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.deDE!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "defaultLanguage" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "defaultLanguage", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.defaultLanguage = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "el-GR" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "el-GR", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.elGR!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "en-GB" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "en-GB", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.enGB!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "en-US" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "en-US", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.enUS!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "es-419" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "es-419", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.es419!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "es-ES" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "es-ES", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "fi-FI" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "fi-FI", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "fr-CA" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "fr-CA", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "fr-FR" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "fr-FR", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "hu-HU" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "hu-HU", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "id-ID" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "id-ID", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "it-IT" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "it-IT", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ja-JP" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "ja-JP", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ko-KR" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "ko-KR", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "nl-NL" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "nl-NL", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "no-NO" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "no-NO", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "pl-PL" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "pl-PL", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "pt-BR" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "pt-BR", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "pt-PT" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "pt-PT", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ro-RO" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "ro-RO", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "ru-RU" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "ru-RU", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "sv-SE" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "sv-SE", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "th-TH" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "th-TH", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "tr-TR" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "tr-TR", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "vi-VN" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "vi-VN", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "zh-Hans" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "zh-Hans", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "zh-Hant" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "zh-Hant", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.localizedParameters!.esES!.titleName = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }

        if AvailableAdvancedParamatersComboBox.stringValue == "creationDate" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "creationDate", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.pubtools!.creationDate = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "loudnessSnd0" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "loudnessSnd0", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.pubtools!.loudnessSnd0 = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            } 
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "submission" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "submission", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.pubtools!.submission = false
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if AvailableAdvancedParamatersComboBox.stringValue == "toolVersion" {
            if NewParameterValue.isNumber {
                BadValueAlert.informativeText = "Only String values allowed."
                BadValueAlert.runModal()
            } else {
                let NewParamTableItem = ParamTableItem(ParameterName: "toolVersion", ParameterValue: NewParameterValue, ParameterType: "String")
                SelectedParamJSON.pubtools!.toolVersion = NewParameterValue
                ParamTableItems.append(NewParamTableItem)
            }
        }
        
        if SelectedParamJSON == nil {
            delegate?.ReceiveJSON(with: nil, with: SelectedManifestJSON)
        } else {
            delegate?.ReceiveJSON(with: SelectedParamJSON, with: nil)
        }

        AdvancedParametersTableView.reloadData()
    }
    
}

