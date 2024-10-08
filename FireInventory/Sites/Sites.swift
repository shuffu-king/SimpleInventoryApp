//
//  Sites.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import Foundation

struct Site: Identifiable, Codable, Hashable {
    var id: String
    let name: String
    let location: String
    var items:  [String: Int]
    var damagedItems: [String: Int]
    var inUseItems: [String: Int]
    var userIDs: [String]
    var robotIDs: [String]
}
