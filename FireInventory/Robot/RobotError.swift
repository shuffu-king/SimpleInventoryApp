//
//  RobotError.swift
//  FireInventory
//
//  Created by Ayo Shafau on 9/4/24.
//

import Foundation

enum RobotError: LocalizedError {
    case robotAlreadyAssigned(siteID: String)
    case robotNotFound
    case invalidRobotData
    
    var errorDescription: String? {
        switch self {
        case .robotAlreadyAssigned(let siteID):
            return "This robot is already assigned to site: \(siteID)."
        case .robotNotFound:
            return "The robot does not exist in the database."
        case .invalidRobotData:
            return "The robot data is invalid or corrupted."
        }
    }
}
