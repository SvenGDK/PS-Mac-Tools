//
//  PS5Manifest.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 16/12/2023.
//

import Foundation

struct PS5Param: Codable {
    var addcont: Addcont?
    var ageLevel: [String : Int]?
    var applicationCategoryType: Int?
    var applicationDRMType: String?
    var attribute, attribute2, attribute3: Int?
    var conceptID: String?
    var contentBadgeType: Int?
    var contentID, contentVersion: String?
    var deeplinkUri: String?
    var downloadDataSize: Int?
    var gameIntent: GameIntent?
    var kernel: Kernel?
    var localizedParameters: LocalizedParameters?
    var masterVersion: String?
    var pubtools: Pubtools?
    var requiredSystemSoftwareVersion: String?
    var sdkVersion: String?
    var titleID: String?
    var savedata: Savedata?
    var userDefinedParam1, userDefinedParam2, userDefinedParam3, userDefinedParam4: Int?
    var versionFileURI: String?

    enum CodingKeys: String, CodingKey {
        case addcont, ageLevel, applicationCategoryType
        case applicationDRMType = "applicationDrmType"
        case attribute, attribute2, attribute3
        case conceptID = "conceptId"
        case contentBadgeType
        case contentID = "contentId"
        case contentVersion, deeplinkUri, downloadDataSize, gameIntent, kernel, localizedParameters, masterVersion, pubtools, requiredSystemSoftwareVersion, savedata, sdkVersion
        case titleID = "titleId"
        case userDefinedParam1, userDefinedParam2, userDefinedParam3, userDefinedParam4
        case versionFileURI = "versionFileUri"
    }
}

struct Addcont: Codable {
    var serviceIDForSharing: [String]?

    enum CodingKeys: String, CodingKey {
        case serviceIDForSharing = "serviceIdForSharing"
    }
}

struct GameIntent: Codable {
    var permittedIntents: [PermittedIntent]?
}

struct PermittedIntent: Codable {
    var intentType: String?
}

struct Kernel: Codable {
    var cpuPageTableSize, flexibleMemorySize, gpuPageTableSize: Int?
}

struct LocalizedParameters: Codable {
    var arAE: ArAE?
    var csCZ: CsCZ?
    var daDK: DaDK?
    var deDE: DeDE?
    var defaultLanguage: String?
    var elGR: ElGR?
    var enGB: EnGB?
    var enUS: EnUS?
    var es419: Es419?
    var esES, fiFI, frCA, frFR: ArAE?
    var huHU, idID, itIT, jaJP: ArAE?
    var koKR, nlNL, noNO, plPL: ArAE?
    var ptBR, ptPT, roRO, ruRU: ArAE?
    var svSE, thTH, trTR, viVN: ArAE?
    var zhHans, zhHant: ArAE?

    enum CodingKeys: String, CodingKey {
        case arAE = "ar-AE"
        case csCZ = "cs-CZ"
        case daDK = "da-DK"
        case deDE = "de-DE"
        case defaultLanguage
        case elGR = "el-GR"
        case enGB = "en-GB"
        case enUS = "en-US"
        case es419 = "es-419"
        case esES = "es-ES"
        case fiFI = "fi-FI"
        case frCA = "fr-CA"
        case frFR = "fr-FR"
        case huHU = "hu-HU"
        case idID = "id-ID"
        case itIT = "it-IT"
        case jaJP = "ja-JP"
        case koKR = "ko-KR"
        case nlNL = "nl-NL"
        case noNO = "no-NO"
        case plPL = "pl-PL"
        case ptBR = "pt-BR"
        case ptPT = "pt-PT"
        case roRO = "ro-RO"
        case ruRU = "ru-RU"
        case svSE = "sv-SE"
        case thTH = "th-TH"
        case trTR = "tr-TR"
        case viVN = "vi-VN"
        case zhHans = "zh-Hans"
        case zhHant = "zh-Hant"
    }
}

struct ArAE: Codable {
    var titleName: String?
}

struct CsCZ: Codable {
    var titleName: String?
}

struct DaDK: Codable {
    var titleName: String?
}

struct DeDE: Codable {
    var titleName: String?
}

struct ElGR: Codable {
    var titleName: String?
}

struct EnGB: Codable {
    var titleName: String?
}

struct EnUS: Codable {
    var titleName: String?
}

struct Es419: Codable {
    var titleName: String?
}

struct Pubtools: Codable {
    var creationDate, loudnessSnd0: String?
    var submission: Bool?
    var toolVersion: String?
}

struct Savedata: Codable {
    var titleIDForSharing: String?

    enum CodingKeys: String, CodingKey {
        case titleIDForSharing = "titleIdForSharing"
    }
}
