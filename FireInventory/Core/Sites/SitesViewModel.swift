//
//  SitesViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/20/24.
//

import Foundation

@MainActor
final class SitesViewModel: ObservableObject {
    
    @Published private(set) var sites: [Site] = []
    @Published private(set) var items: [Item] = []
    
    func getAllSites() async throws {
        guard let userId = AuthenticationManager.shared.getCurrentUserId() else { return }
        self.sites = try await SitesManager.shared.getAllSites(for: userId)
    }
    
    func getAllItems() async throws {
        self.items = try await ItemsManager.shared.getAllItems()
    }
    
    func getItemName(by id: String) -> String {
        return items.first { $0.id == id }?.itemName ?? "Unknown Item"
    }
    
    func updateItemQuantity(siteId: String, itemId: String, change: Int, type: String, notes: String){
        guard let userID = AuthenticationManager.shared.getCurrentUserId() else { return }
        guard let siteIndex = sites.firstIndex(where: {$0.id == siteId}) else { return }
        
        if var currentQuantity = sites[siteIndex].items[itemId] {
            currentQuantity = max(0, currentQuantity + change)
            sites[siteIndex].items[itemId] = currentQuantity
        } else {
            sites[siteIndex].items[itemId] = max(0, change)
        }
        
        
        Task {
            try await SitesManager.shared.updateSiteItemQuantity(siteId: siteId, itemId: itemId, quantity: change)
            try await SitesManager.shared.addTransaction(siteID: siteId, itemID: itemId, quantity: change, userID: userID, type: type, notes: notes)
        }
    }
    
}
