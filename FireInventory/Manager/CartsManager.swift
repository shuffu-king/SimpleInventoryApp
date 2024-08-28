//
//  CartsManager.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/4/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class CartsManager {
    
    static let shared = CartsManager()
    private let db = Firestore.firestore()
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    private let currentUser = AuthenticationManager.shared.getCurrentUserEmail() ?? "unknown"

    func getCarts(for siteId: String) async throws -> [Cart] {
        let cartsCollection = db.collection("sites").document(siteId).collection("carts")
        let snapshot = try await cartsCollection.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Cart.self) }
    }
    
    func addCart(_ cart: Cart, to site: Site) async throws {
        let cartsCollection = db.collection("sites").document(site.id).collection("carts")
        try cartsCollection.document(cart.name).setData(from: cart)
        let transactionRecord = Transaction(entityType: "cart", entityId: cart.name, siteId: site.name, action: "cart creation", userId: currentUser)
        try transactionsCollection.addDocument(from: transactionRecord)
    }
    
    func updateCart(_ cart: Cart, in siteId: String) async throws {
        let cartsCollection = db.collection("sites").document(siteId).collection("carts")
        try cartsCollection.document(cart.name).setData(from: cart)
    }
    
    func deleteCart(named cartName: String, from site: Site) async throws {
        let cartsCollection = db.collection("sites").document(site.id).collection("carts")
        try await cartsCollection.document(cartName).delete()
        let transactionRecord = Transaction(entityType: "cart", entityId: cartName, siteId: site.name, action: "cart deletion", userId: currentUser)
        try transactionsCollection.addDocument(from: transactionRecord)
    }
    
    func swapRobot(in cart: Cart, at position: PartPosition, with newRobotSN: String, for site: Site, notes: String?) async throws {
        let oldRobotSN: String?
        var updatedCart = cart
        switch position {
        case .TL:
            oldRobotSN = cart.TLserialNumber
            updatedCart.TLserialNumber = newRobotSN
        case .TR:
            oldRobotSN = cart.TRserialNumber
            updatedCart.TRserialNumber = newRobotSN
        case .BL:
            oldRobotSN = cart.BLserialNumber
            updatedCart.BLserialNumber = newRobotSN
        case .BR:
            oldRobotSN = cart.BRserialNumber
            updatedCart.BRserialNumber = newRobotSN
        }
        //update cart
        try await updateCart(updatedCart, in: site.id)
        
        //Mark old robot as damaged
        if let oldRobotSN = oldRobotSN {
            let robotRef = db.collection("robots").document(oldRobotSN)
            try await robotRef.updateData(["health": RobotHealth.damaged.rawValue, "notes": notes as Any])
            
            //create and add new transaction
            let transactionRecord = Transaction(entityType: "wheel", entityId: oldRobotSN, siteId: site.name, action: "swap wheel cart", userId: currentUser, notes: "Cart Name: \(cart.name), Issue: \(notes ?? "N/A")", newEntityId: newRobotSN)
            try transactionsCollection.addDocument(from: transactionRecord)
        }
    }
    
    func getCartForRobot(robotSerialNumber: String, siteId: String) async throws -> Cart? {
            let cartsCollection = db.collection("sites").document(siteId).collection("carts")
            let snapshot = try await cartsCollection.whereField("TLserialNumber", isEqualTo: robotSerialNumber)
                .getDocuments()
            
            if let cartDocument = snapshot.documents.first {
                return try cartDocument.data(as: Cart.self)
            }
            
            let otherPositions = ["TRserialNumber", "BLserialNumber", "BRserialNumber"]
            
            for position in otherPositions {
                let positionSnapshot = try await cartsCollection.whereField(position, isEqualTo: robotSerialNumber).getDocuments()
                if let cartDocument = positionSnapshot.documents.first {
                    return try cartDocument.data(as: Cart.self)
                }
            }
            
            return nil
        }
    
}
