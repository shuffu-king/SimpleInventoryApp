//
//  Robot.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/24/24.
//

import Foundation



struct Robot: Identifiable, Codable {
    var id: String {serialNumber}
    let serialNumber: String
    let position: PartPosition
    

}

enum PartPosition: String, Codable, CaseIterable, Hashable {
    case TL = "Top left"
    case TR = "Top right"
    case BL = "Back left"
    case BR = "Back right"
}
