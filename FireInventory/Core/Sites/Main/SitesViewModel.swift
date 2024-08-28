//
//  SitesViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/20/24.
//

import Foundation

@MainActor
final class SitesViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
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
    
    func deleteSite(_ site: Site) async throws {
        try await SitesManager.shared.deleteSite(site: site)
        sites.removeAll { $0.id == site.id }
    }
    
    func getAllItems() async throws {
        self.items = try await ItemsManager.shared.getAllItems()
        self.damagedItems = try await ItemsManager.shared.getAllItems()
    }
    
    func getItemName(by id: String) -> String {
        return items.first { $0.id == id }?.itemName ?? "Unknown Item"
    }
    
    func updateItemQuantity(site: Site, itemId: String, change: Int, type: String, notes: String, userId: String, isDamaged: Bool = false){
        guard let userID = AuthenticationManager.shared.getCurrentUserEmail() else { return }
        guard let siteIndex = sites.firstIndex(where: {$0.id == site.id}) else { return }
        
        if isDamaged {
            if var currentQuantity = sites[siteIndex].damagedItems[itemId] {
                currentQuantity = max(0, currentQuantity + change)
                sites[siteIndex].damagedItems[itemId] = currentQuantity
            } else {
                sites[siteIndex].damagedItems[itemId] = max(0, change)
            }
            
            if var availableQuantity = sites[siteIndex].items[itemId] {
                availableQuantity = max(0, availableQuantity - change)
                sites[siteIndex].items[itemId] = availableQuantity
            } else {
                sites[siteIndex].items[itemId] = max(0, change)
            }
            
        } else {
            if type == "Add" {
                if var currentQuantity = sites[siteIndex].items[itemId] {
                    currentQuantity = max(0, currentQuantity + change)
                    sites[siteIndex].items[itemId] = currentQuantity
                } else {
                    sites[siteIndex].items[itemId] = max(0, change)
                }
            }
        }
        
        Task {
            try await SitesManager.shared.updateSiteItemQuantity(siteId: site.id, itemId: itemId, quantity: change, isDamaged: isDamaged)
            let transactionRecord = Transaction(entityType: isDamaged ? "damaged item" : "item" , entityId: itemId, siteId: site.name, action: type, userId: userID, notes: notes)
            try await SitesManager.shared.addTransaction(transactionRecord)
        }
    }
    
    func updateInUseItemQuantity(site: Site, itemId: String, change: Int, type: String, notes: String, userId: String) async throws {
        guard let userID = AuthenticationManager.shared.getCurrentUserEmail() else { return }
        guard let siteIndex = sites.firstIndex(where: {$0.id == site.id}) else { return }
        
        if var currentQuantity = sites[siteIndex].inUseItems[itemId] {
            currentQuantity =  type == "Add" ? max(0, currentQuantity + change) : max(0, currentQuantity - change)
            sites[siteIndex].inUseItems[itemId] = currentQuantity
        } else {
            sites[siteIndex].inUseItems[itemId] = max(0, change)
        }
        
        if type == "Add" {
            if var availableQuantity = sites[siteIndex].items[itemId] {
                availableQuantity = max(0, availableQuantity - change)
                sites[siteIndex].items[itemId] = availableQuantity
            } else {
                sites[siteIndex].items[itemId] = max(0, change)
            }
            
        } else if type == "Remove"{
            if var damagedQuantity = sites[siteIndex].damagedItems[itemId] {
                damagedQuantity = max(0, damagedQuantity + change)
                sites[siteIndex].damagedItems[itemId] = damagedQuantity
            } else {
                sites[siteIndex].damagedItems[itemId] = max(0, change)
            }
        }
        
        Task {
            try await SitesManager.shared.updateSiteInUseItemQuantity(siteId: site.id, itemId: itemId, quantity: type == "Add" ? change : -change)
            try await SitesManager.shared.updateSiteItemQuantity(siteId: site.id, itemId: itemId, quantity: type == "Add" ? -change : change, isDamaged: type == "Add" ? false : true)
            let transactionRecord = Transaction(entityType: "in-use item" , entityId: itemId, siteId: site.name, action: type, userId: userID, notes: notes)
            try await SitesManager.shared.addTransaction(transactionRecord)
            
        }
    }
    
    func transferItems(itemID: String, quantity: Int, from currentSite: Site, to newSite: Site, itemName: String) async throws {
        try await SitesManager.shared.transferItem(itemID: itemID, quantity: quantity, from: currentSite, to: newSite, itemName: itemName)
        let refreshedSite = try await SitesManager.shared.refreshAllItems(for: newSite.id)
        if let siteIndex = sites.firstIndex(where: { $0.id == refreshedSite.id}) {
            sites[siteIndex] = refreshedSite
        }
        
    }
    
    func fetchTransactions(for siteId: String) async throws {
        var fetchedTransactions = try await SitesManager.shared.getTransactions(for: siteId)
        
        fetchedTransactions.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
        DispatchQueue.main.async {
            self.transactions = fetchedTransactions
        }
    }
}
