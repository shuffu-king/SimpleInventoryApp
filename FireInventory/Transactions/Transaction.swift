//
//  Transaction.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/19/24.
//

import Foundation
import FirebaseFirestore

struct Transaction: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let entityType: String
    let entityId: String
    let siteId: String
    let quantity: Int?
    let userId: String
    let timestamp: Timestamp
    let action: String
    let notes: String?
    let newSiteId: String?
    let image: String?
    let newEntityId: String?
    
    
    init(entityType: String, entityId: String, siteId: String, action: String, userId: String, quantity: Int? = nil, notes: String? = nil, newSiteId: String? = nil, image: String? = nil, newEntityId: String? = nil) {
        self.entityType = entityType
        self.entityId = entityId
        self.siteId = siteId
        self.action = action
        self.timestamp = Timestamp()
        self.userId = userId
        self.quantity = quantity
        self.notes = notes
        self.newSiteId = newSiteId
        self.image = image
        self.newEntityId = newEntityId
    }
}
