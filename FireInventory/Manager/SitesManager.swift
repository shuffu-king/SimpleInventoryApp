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
    
    //fetch all sites
    func getAllSites(for userId: String) async throws -> [Site] {
        let snapshot = try await sitesCollection.whereField("userIDs", arrayContains: userId).getDocuments()
        return snapshot.documents.compactMap{ try? $0.data(as: Site.self) }
    }
    
    //add a new site
    func addSite(_ site: Site) async throws {
        var newSite = site
        newSite.userIDs.append(currentUser)
        try sitesCollection.document(newSite.id).setData(from: newSite)
        let transactionRecord = Transaction(entityType: "site", entityId: site.id, siteId: site.id, action: "site creation", userId: currentUser)
        try await addTransaction(transactionRecord)
    }
    
    //delete a site
    func deleteSite(siteId: String) async throws {
        let siteRef = siteDocument(siteId: siteId)
        try await siteRef.delete()
        //create transaction record
        let transactionRecord = Transaction(entityType: "site", entityId: siteId, siteId: siteId, action: "site deletion", userId: currentUser)
        try await addTransaction(transactionRecord)
    }
    
    func updateSiteItemQuantity(siteId: String, itemId: String, quantity: Int, isDamaged: Bool = false) async throws {
        let siteRef = sitesCollection.document(siteId)
        let fieldKey = isDamaged ? "damagedItems.\(itemId)" : "items.\(itemId)"
        try await siteRef.updateData([
            fieldKey : FieldValue.increment(Int64(quantity))
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
    
    
    //get all available sites excluding current
    func getAvailableSites(for userId: String, excluding siteId: String) async throws -> [Site] {
        let sites = try await getAllSites(for: userId)
        return sites.filter { $0.id != siteId }
    }
    
    //Swap robot between sites
    func siteRobotSwap(robotID: String, from currentSiteId: String, to newSiteId: String) async throws {
        
        // Remove the robot from the current site
        let currentSiteRef = sitesCollection.document(currentSiteId)
        try await currentSiteRef.updateData([
            "robotIDs": FieldValue.arrayRemove([robotID])
        ])
        print("Removed robot from current site: \(currentSiteId)")

        // Add the robot to the new site
        let newSiteRef = sitesCollection.document(newSiteId)
        try await newSiteRef.updateData([
            "robotIDs": FieldValue.arrayUnion([robotID])
        ])
        print("Added robot to new site: \(newSiteId)")
        
        //Update robot's siteID
        let robotRef = Firestore.firestore().collection("robots").document(robotID)
            try await robotRef.updateData([
                "siteID": newSiteId
            ])
        
        // Create a transaction record
        let transactionRecord = Transaction(entityType: "robot", entityId: robotID, siteId: currentSiteId, action: "robot swap", userId: currentUser, notes: "Transfered robot \(robotID) from site \(currentSiteId) to site \(newSiteId)", newSiteId: newSiteId)
        print("Transaction recorded for robot swap")
        
        try await addTransaction(transactionRecord)
    }
    
    func transferItem(itemID: String, quantity: Int, from currentSiteId: String, to newSiteId: String, itemName: String) async throws {
        let currentSiteRef = sitesCollection.document(currentSiteId)
        let newSiteRef = sitesCollection.document(newSiteId)
        
        // Remove the specified quantity from the current site
        try await currentSiteRef.updateData([
            "items.\(itemID)": FieldValue.increment(Int64(-quantity))
        ])
        print("Removed \(quantity) of item \(itemID) from current site: \(currentSiteId)")
        
        // Add the specified quantity to the new site
        try await newSiteRef.updateData([
            "items.\(itemID)": FieldValue.increment(Int64(quantity))
        ])
        print()
        
        // Create a transaction record
        let transactionRecord = Transaction(entityType: "item", entityId: itemID, siteId: currentSiteId, action: "item transfer", userId: currentUser, quantity: quantity, notes: "Added \(quantity) of item \(itemName) to new site: \(newSiteId)", newSiteId: newSiteId)
        print("Transaction recorded for item transfer")
        
        try await addTransaction(transactionRecord)
    }
}
