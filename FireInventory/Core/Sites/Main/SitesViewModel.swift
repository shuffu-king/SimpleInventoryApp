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
    @Published private(set) var damagedItems: [Item] = []
    @Published private(set) var robots: [Robot] = []
    @Published var currentUser = AuthenticationManager.shared.getCurrentUserId() ?? "unknown"
    
    func getAllSites() async throws {
        guard let userId = AuthenticationManager.shared.getCurrentUserId() else {
            print("UserID not found")
            return
        }
        self.sites = try await SitesManager.shared.getAllSites(for: userId)
    }
    
    func addSite(_ site: Site) async throws {
        try await SitesManager.shared.addSite(site)
        try await getAllSites()
    }
    
    func deleteSite(_ siteId: String) async throws {
        try await SitesManager.shared.deleteSite(siteId: siteId)
        sites.removeAll { $0.id == siteId }
    }
    
    func getAllItems() async throws {
        self.items = try await ItemsManager.shared.getAllItems()
        self.damagedItems = try await ItemsManager.shared.getAllItems()
    }
    
    func getItemName(by id: String) -> String {
        return items.first { $0.id == id }?.itemName ?? "Unknown Item"
    }
    
    func updateItemQuantity(siteId: String, itemId: String, change: Int, type: String, notes: String, userId: String, isDamaged: Bool = false){
        guard let userID = AuthenticationManager.shared.getCurrentUserId() else { return }
        guard let siteIndex = sites.firstIndex(where: {$0.id == siteId}) else { return }
        
        if isDamaged {
            if var currentQuantity = sites[siteIndex].damagedItems[itemId] {
                currentQuantity = max(0, currentQuantity + change)
                sites[siteIndex].damagedItems[itemId] = currentQuantity
            } else {
                sites[siteIndex].damagedItems[itemId] = max(0, change)
            }
        } else {
            if var currentQuantity = sites[siteIndex].items[itemId] {
                currentQuantity = max(0, currentQuantity + change)
                sites[siteIndex].items[itemId] = currentQuantity
            } else {
                sites[siteIndex].items[itemId] = max(0, change)
            }
        }
        
        Task {
            try await SitesManager.shared.updateSiteItemQuantity(siteId: siteId, itemId: itemId, quantity: change, isDamaged: isDamaged)
            let transactionRecord = Transaction(entityType: isDamaged ? "damaged item" : "item" , entityId: itemId, siteId: siteId, action: type, userId: userID, notes: notes)
            try await SitesManager.shared.addTransaction(transactionRecord)
        }
    }
    
    func transferItems(itemID: String, quantity: Int, from currentSiteId: String, to newSiteId: String, itemName: String) async throws {
        try await SitesManager.shared.transferItem(itemID: itemID, quantity: quantity, from: currentSiteId, to: newSiteId, itemName: itemName)
        try await getAllItems()
    }
}
