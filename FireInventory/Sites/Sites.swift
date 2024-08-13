//
//  Sites.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import Foundation

struct Site: Identifiable, Codable {
    let id: String
    let name: String
    let location: String
    var items:  [String: Int]
    let userIDs: [String]
    var robotIDs: [String]
}
