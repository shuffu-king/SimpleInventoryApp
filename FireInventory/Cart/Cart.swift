//
//  Cart.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/30/24.
//

import Foundation

struct Cart: Identifiable, Codable {
    var id: String
    var name: String
    var TLserialNumber: String?
    var TRserialNumber: String?
    var BLserialNumber: String?
    var BRserialNumber: String?
}

