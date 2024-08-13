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
    
    
    private let db = Firestore.firestore()
    private let sitesCollection = Firestore.firestore().collection("sites")
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    private let currentUser = AuthenticationManager.shared.getCurrentUserId() ?? "unknown"
    
    private func siteDocument(siteId: String) -> DocumentReference {
        sitesCollection.document(siteId)
    }
    
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
    
    func updateSiteRobots(siteID: String, robotID: String, add: Bool) async throws {
        let siteRef = sitesCollection.document(siteID)
        try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let siteDocument = try transaction.getDocument(siteRef)
                guard var site = try siteDocument.data(as: Site?.self) else {
                    return nil
                }
                
                if add {
                    site.robotIDs.append(robotID)
                } else {
                    site.robotIDs.removeAll { $0 == robotID }
                }
                
                try transaction.setData(from: site, forDocument: siteRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func addTransaction(_ transaction: Transaction) async throws {
        // Logic to add a transaction
        try transactionsCollection.addDocument(from: transaction)
    }
}
