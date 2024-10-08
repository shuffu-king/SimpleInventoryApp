//
//  Robot.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/24/24.
//

import Foundation

struct Robot: Identifiable, Codable, Hashable {
    var id: String {serialNumber}
    let serialNumber: String
    let position: PartPosition
    let version: RobotVersion
    var health: RobotHealth
    var siteID: String
    var notes: String?
    var wheelType: String {
            switch position {
            case .TL, .BR:
                return "Mecanum-TL-BR"
            case .TR, .BL:
                return "Mecanum-TR-BL"
            }
        } // New property for wheel item
    var wheelInstallationDate: Date? // Track when the wheel was installed
    var cartAssigned: String?
    var rsosFinished: Bool?
}

enum PartPosition: String, Codable, CaseIterable, Hashable {
    case TL = "Top left"
    case TR = "Top right"
    case BL = "Back left"
    case BR = "Back right"
}

enum RobotVersion: String, Codable, CaseIterable {
    case G1 = "1.0"
    case G20 = "2.0"
    case G21 = "2.1"
    case G22 = "2.2"
}

enum RobotHealth: String, Codable, CaseIterable {
    case new, damaged, refurbished
}
