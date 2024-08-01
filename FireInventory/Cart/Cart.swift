//
//  Cart.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/30/24.
//

import Foundation

struct Cart: Identifiable, Codable {
    let id: String
    let name: String
    let password: String?
    var robots: [Robot]
}

