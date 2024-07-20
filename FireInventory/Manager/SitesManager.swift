//
//  SitesManager.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SitesManager {
    
    static let shared = SitesManager()
    private init() { }
    
    private let sitesCollection = Firestore.firestore().collection("sites")
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    
    private func siteDocument(siteId: String) -> DocumentReference {
        sitesCollection.document(siteId)
    }
    
//    func getAllSites() async throws -> [Site] {
//        let snapshot = try await sitesCollection.getDocuments()
//        
//        var sites: [Site] = []
//        for document in snapshot.documents {
//            let site = try document.data(as: Site.self)
//            sites.append(site)
//            
//            
//        }
//        return sites
//        
//    }
    
    func getAllSites(for userId: String) async throws -> [Site] {
        let snapshot = try await sitesCollection.whereField("userIDs", arrayContains: userId).getDocuments()
        return snapshot.documents.compactMap{ try? $0.data(as: Site.self) }
    }
    
    func updateSiteItemQuantity(siteId: String, itemId: String, quantity: Int) async throws {
        let siteRef = sitesCollection.document(siteId)
        try await siteRef.updateData([
            "items.\(itemId)" : FieldValue.increment(Int64(quantity))
        ])
    }
    
    func addTransaction(siteID: String, itemID: String, quantity: Int, userID: String, type: String, notes: String) async throws {
        let transaction = Transaction(siteID: siteID, itemID: itemID, quantity: quantity, userID: userID, timestamp: Timestamp(), notes: notes, type: type)
        
        let _ = try transactionsCollection.addDocument(from: transaction)
    }
    
}
