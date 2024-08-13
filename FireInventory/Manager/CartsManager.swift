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
    private let currentUser = AuthenticationManager.shared.getCurrentUserId() ?? "unknown"
    
    func getCarts(for siteId: String) async throws -> [Cart] {
        let cartsCollection = db.collection("sites").document(siteId).collection("carts")
        let snapshot = try await cartsCollection.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Cart.self) }
    }
    
    func addCart(_ cart: Cart, to siteId: String) async throws {
        let cartsCollection = db.collection("sites").document(siteId).collection("carts")
        try cartsCollection.document(cart.name).setData(from: cart)
        let transactionRecord = Transaction(entityType: "cart", entityId: cart.name, siteId: siteId, action: "cart_creation", userId: currentUser)
        try transactionsCollection.addDocument(from: transactionRecord)
    }
    
    func updateCart(_ cart: Cart, in siteId: String) async throws {
        let cartsCollection = db.collection("sites").document(siteId).collection("carts")
        try cartsCollection.document(cart.name).setData(from: cart)
    }
    
    func deleteCart(named cartName: String, from siteId: String) async throws {
        let cartsCollection = db.collection("sites").document(siteId).collection("carts")
        try await cartsCollection.document(cartName).delete()
        let transactionRecord = Transaction(entityType: "cart", entityId: cartName, siteId: siteId, action: "cart_deletion", userId: currentUser)
        try transactionsCollection.addDocument(from: transactionRecord)
    }
    
    func swapRobot(in cart: Cart, at position: PartPosition, with newRobotSN: String, for siteId: String, notes: String?) async throws {
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
        try await updateCart(updatedCart, in: siteId)
        
        //Mark old robot as damaged
        if let oldRobotSN = oldRobotSN {
            let robotRef = db.collection("robots").document(oldRobotSN)
            try await robotRef.updateData(["health": RobotHealth.damaged.rawValue, "notes": notes as Any])
        }
        //create and add new transaction
        let transactionRecord = Transaction(entityType: "cart", entityId: cart.name, siteId: siteId, action: "swap_robot", userId: currentUser, notes: notes)
        try transactionsCollection.addDocument(from: transactionRecord)
    }
    
    
}
