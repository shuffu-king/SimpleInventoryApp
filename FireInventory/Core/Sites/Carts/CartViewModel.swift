//
//  CartViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class CartViewModel: ObservableObject {
    @Published var carts: [Cart] = []
    @Published var expandedCartID: String?
    @Published var newCartName: String = ""
    @Published var newCartPassword: String = ""
//    @Published var selectedRobots: [Robot.PartPosition: Robot] = [:]
    
    let sitesCollection = Firestore.firestore().collection("sites")
    
    func getAllCarts(for siteId: String) async throws {
        let cartsCollection = sitesCollection.document(siteId).collection("carts")
        let snapshot = try await cartsCollection.getDocuments()
        self.carts = snapshot.documents.compactMap { try? $0.data(as: Cart.self) }
    }
    
    func addCart(for siteId: String, cart: Cart) async throws {
        let cartsCollection = sitesCollection.document(siteId).collection("carts")
        try await cartsCollection.document(cart.id).setData(from: cart)
    }
    
    func deleteCart(for siteId: String, cartId: String) async throws {
        let cartsCollection = sitesCollection.document(siteId).collection("carts")
        try await cartsCollection.document(cartId).delete()
    }
    
    func updateCart(for siteId: String, cart: Cart) async throws {
        let cartsCollection = sitesCollection.document(siteId).collection("carts")
        try await cartsCollection.document(cart.id).setData(from: cart)
    }
    
    func toggleCartExpansion(cartId: String) {
        if expandedCartID == cartId {
            expandedCartID = nil
        } else {
            expandedCartID = cartId
        }
    }
}
