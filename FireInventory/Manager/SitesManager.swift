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
    private let robotsCollection = Firestore.firestore().collection("robots")
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    private let currentUserId = AuthenticationManager.shared.getCurrentUserId() ?? "unknown"
    private let currentUser = AuthenticationManager.shared.getCurrentUserEmail() ?? "unknown"
    
    private func siteDocument(siteId: String) -> DocumentReference {
        sitesCollection.document(siteId)
    }
    
    private func robotDocument(id: String) -> DocumentReference {
        robotsCollection.document(id)
    }
    
    //fetch all sites
    func getAllSites(for userId: String) async throws -> [Site] {
        let snapshot = try await sitesCollection.whereField("userIDs", arrayContains: userId).getDocuments()
        return snapshot.documents.compactMap{ try? $0.data(as: Site.self) }
    }
    
    func refreshAllItems(for siteId: String) async throws -> Site {
        let siteDoc = siteDocument(siteId: siteId)
        let snapshot = try await siteDoc.getDocument()
        
        guard let site = try snapshot.data(as: Site?.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Site not found"])
        }
        
        return site
    }
    
    //add a new site
    func addSite(_ site: Site) async throws {
        var newSite = site
        newSite.userIDs.append(currentUserId)
        try sitesCollection.document(newSite.id).setData(from: newSite)
        let transactionRecord = Transaction(entityType: "site", entityId: site.id, siteId: site.name, action: "site creation", userId: currentUser)
        try await addTransaction(transactionRecord)
    }
    
    //delete a site
    func deleteSite(site: Site) async throws {
        let siteRef = siteDocument(siteId: site.id)
        try await siteRef.delete()
        
        let querySnapshot = try await robotsCollection.whereField("siteID", isEqualTo: site.id).getDocuments()
        
        for document in querySnapshot.documents {
            let robotDoc = document.reference
            try await robotDoc.updateData([
                "siteID": FieldValue.delete() // Remove the siteId field from the robot
            ])
        }
        
        //create transaction record
        let transactionRecord = Transaction(entityType: "site", entityId: site.id, siteId: site.name, action: "site deletion", userId: currentUser)
        try await addTransaction(transactionRecord)
    }
    
    func updateSiteItemQuantity(siteId: String, itemId: String, quantity: Int, isDamaged: Bool = false) async throws {
        let siteRef = sitesCollection.document(siteId)
        let fieldKey = isDamaged ? "damagedItems.\(itemId)" : "items.\(itemId)"
        try await siteRef.updateData([
            fieldKey : FieldValue.increment(Int64(quantity))
        ])
    }
    
    func updateSiteInUseItemQuantity(siteId: String, itemId: String, quantity: Int) async throws {
        let siteRef = sitesCollection.document(siteId)
        let fieldKey = "inUseItems.\(itemId)"
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
    
    func getTransactions(for siteId: String) async throws -> [Transaction] {
        let querySnapshot = try await transactionsCollection
            .whereField("siteId", isEqualTo: siteId)
            .getDocuments()
        
        var transactions: [Transaction] = []
        
        for document in querySnapshot.documents {
            if let transaction = try? document.data(as: Transaction.self) {
                transactions.append(transaction)
            }
        }
        
        return transactions
    }
    
    //get all available sites excluding current
    func getAvailableSites(for userId: String, excluding siteId: String) async throws -> [Site] {
        let sites = try await getAllSites(for: userId)
        return sites.filter { $0.id != siteId }
    }
    
    //Swap robot between sites
    func siteRobotSwap(robotID: String, from currentSite: Site, to newSite: Site) async throws {
        
        // Remove the robot from the current site
        let currentSiteRef = sitesCollection.document(currentSite.id)
        try await currentSiteRef.updateData([
            "robotIDs": FieldValue.arrayRemove([robotID])
        ])
        print("Removed robot from current site: \(currentSite.name)")
        
        // Add the robot to the new site
        let newSiteRef = sitesCollection.document(newSite.id)
        try await newSiteRef.updateData([
            "robotIDs": FieldValue.arrayUnion([robotID])
        ])
        print("Added robot to new site: \(newSite.id)")
        
        //Update robot's siteID
        let robotRef = Firestore.firestore().collection("robots").document(robotID)
        try await robotRef.updateData([
            "siteID": newSite.id
        ])
        
        // Create a transaction record
        let transactionRecord = Transaction(entityType: "robot", entityId: robotID, siteId: currentSite.name, action: "robot swap", userId: currentUser, notes: "Transfered robot \(robotID) from site \(currentSite.name) to site \(newSite.name)", newSiteId: newSite.name)
        print("Transaction recorded for robot swap")
        
        try await addTransaction(transactionRecord)
    }
    
    func transferItem(itemID: String, quantity: Int, from currentSite: Site, to newSite: Site, itemName: String) async throws {
        let currentSiteRef = sitesCollection.document(currentSite.id)
        let newSiteRef = sitesCollection.document(newSite.id)
        
        // Remove the specified quantity from the current site
        try await currentSiteRef.updateData([
            "items.\(itemID)": FieldValue.increment(Int64(-quantity))
        ])
        print("Removed \(quantity) of item \(itemID) from current site: \(currentSite.id)")
        
        // Add the specified quantity to the new site
        try await newSiteRef.updateData([
            "items.\(itemID)": FieldValue.increment(Int64(quantity))
        ])
        print()
        
        // Create a transaction record
        let transactionRecord = Transaction(entityType: "item", entityId: itemID, siteId: currentSite.name, action: "item transfer", userId: currentUser, quantity: quantity, notes: "Added \(quantity) of item \(itemName) to new site: \(newSite.name)", newSiteId: newSite.name)
        print("Transaction recorded for item transfer")
        
        try await addTransaction(transactionRecord)
    }
    
    func changeRobotWheel(robot: Robot, site: Site) async throws {
        // Determine the wheel type based on the robot's position
        let wheelType = robot.wheelType
        
        // Update the site to subtract 1 from the respective wheel item quantity
        let siteRef = sitesCollection.document(site.id)
        try await siteRef.updateData([
            "items.\(wheelType)": FieldValue.increment(Int64(-1))
        ])
        
        //Update the site to add 1 to the damaged respective wheel item quantity
        if robot.wheelInstallationDate != nil {
            try await siteRef.updateData([
                "damagedItems.\(wheelType)": FieldValue.increment(Int64(+1))
            ])
        }
        
        // Update the robot's last wheel change date and save the robot back to Firestore
        let robotRef = Firestore.firestore().collection("robots").document(robot.id)
        try await robotRef.updateData([
            "wheelInstallationDate": Date()
        ])
        
        // Record a transaction for the wheel change
        let transactionRecord = Transaction(
            entityType: "robot",
            entityId: robot.id,
            siteId: site.name,
            action: "wheel change",
            userId: currentUser,
            notes: "Changed \(wheelType) on robot \(robot.serialNumber)"
        )
        try await addTransaction(transactionRecord)
    }
    
    
}
