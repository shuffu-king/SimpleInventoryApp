//
//  ItemsManager.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ItemsManager {
    
    static let shared = ItemsManager()
    private init() { }
    
    private let itemsCollection = Firestore.firestore().collection("items")
    
    private func itemDocument(id: String) -> DocumentReference {
        itemsCollection.document(id)
    }
    
    func getAllItems() async throws -> [Item] {
        let snapshot = try await itemsCollection.getDocuments()
        
        var items: [Item] = []
        for document in snapshot.documents {
            let item = try document.data(as: Item.self)
            items.append(item)
            
        }
        
        return items
    }
}
