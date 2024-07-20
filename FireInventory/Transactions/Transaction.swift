//
//  Transaction.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/19/24.
//

import Foundation
import FirebaseFirestore

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    let siteID: String
    let itemID: String
    let quantity: Int
    let userID: String
    let timestamp: Timestamp
    let notes: String
    let type: String
    
}
