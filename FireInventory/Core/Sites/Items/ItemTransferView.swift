//
//  ItemTransferView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/14/24.
//

import SwiftUI

struct ItemTransferView: View {
    
    @ObservedObject var viewModel: SitesViewModel
    let site: Site
    @Binding var transferPresented: Bool
    @State private var selectedItemID: String = ""
    @State private var transferQuantity: Int = 1
    @State private var selectedSite: Site? = nil
    @State private var availableSites: [Site] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Item") {
                    Picker("Item", selection: $selectedItemID) {
                        ForEach(site.items.keys.sorted(), id: \.self) { itemID in
                            Text(itemID).tag(itemID)
                        }
                    }
                }
                
                Section("Transfer Quantity") {
                    Stepper(value: $transferQuantity, in: 0...site.items[selectedItemID, default: 0]) {
                        Text("\(transferQuantity)")
                    }
                }
                
                Section("Select Destination Site") {
                    Picker("Site", selection: $selectedSite) {
                        ForEach(availableSites, id: \.id) { site in
                            Text(site.name).tag(site as Site?)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
            }
            .navigationTitle("Transfer Item")
            .task {
                await loadAvailableSites()
            }
            .onAppear {
                if selectedItemID.isEmpty, let firstItemId = site.items.keys.sorted().first {
                    selectedItemID = firstItemId
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Transfer") {
                        Task {
                            if let selectedSite = selectedSite {
                                try await viewModel.transferItems(itemID: selectedItemID, quantity: transferQuantity, from: site, to: selectedSite, itemName: selectedItemID)
                            }
                        }
                        transferPresented = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        transferPresented = false
                    }
                }
            }
        }
    }
    
    private func loadAvailableSites() async {
        do {
            let sites = try await SitesManager.shared.getAvailableSites(for: AuthenticationManager.shared.getCurrentUserId() ?? "unknown", excluding: site.id)
            availableSites = sites
            
            if let firstSite = availableSites.first {
                selectedSite = firstSite
            }
        } catch {
            alertMessage = "Failed to load sites: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    ItemTransferView(viewModel: SitesViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), transferPresented: .constant(true))
}
