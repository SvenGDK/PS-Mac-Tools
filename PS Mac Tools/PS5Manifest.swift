//
//  PS5Manifest.swift
//  PS Mac Tools
//
//  Created by SvenGDK on 16/12/2023.
//

import Foundation

struct PS5Manifest: Codable {
    var applicationName: String?
    var applicationVersion: String?
    var commitHash: String?
    var bootAnimation: String?
    var titleID: String?
    var reactNativePlaystationVersion: String?
    var applicationData: ApplicationData?
    var twinTurbo: Bool?

    enum CodingKeys: String, CodingKey {
        case applicationName = "applicationName"
        case applicationVersion = "applicationVersion"
        case commitHash = "commitHash"
        case bootAnimation = "bootAnimation"
        case titleID = "titleId"
        case reactNativePlaystationVersion = "reactNativePlaystationVersion"
        case applicationData = "applicationData"
        case twinTurbo = "twinTurbo"
    }
}

struct ApplicationData: Codable {
    var branchType: String?
}
