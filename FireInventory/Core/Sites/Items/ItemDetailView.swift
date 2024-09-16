//
//  ItemDetailView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/23/24.
//

import SwiftUI

struct ItemDetailView: View {
    
    @State var itemID: String
    @State var quantity: Int = 0
    @ObservedObject var viewModel: SitesViewModel
    @State private var selectedAction: Action = .remove
    let site: Site
    @Binding var isDamaged: Bool
    @State private var showTransferPicker = false
    @State private var showTransferSiteAlert = false
    @State private var selectedSite: Site? = nil
    @State private var availableSites: [Site] = []
    
    enum Action: String, CaseIterable, Identifiable {
        case add = "Add"
        case remove = "Remove"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            if isDamaged {
                
                Text("Damaged Item: \(itemID)")
                    .font(.headline)
                    .foregroundStyle(Color.offWhite)
                
                Text("\(site.damagedItems[itemID] ?? 0)")
                    .font(.title)
                    .foregroundStyle(Color.offWhite)
                
                HStack {
                    Text("Action:")
                        .foregroundStyle(Color.offWhite)
                    
                    Text("Remove from Damaged, Add to Available")
                        .font(.headline)
                        .foregroundStyle(Color.offWhite)
                }
                
            } else {
                
                Text("Current Item: \(itemID)")
                    .font(.headline)
                    .foregroundStyle(Color.offWhite)
                
                Text("\(site.items[itemID] ?? 0)")
                    .font(.title)
                    .foregroundStyle(Color.offWhite)
                
                HStack {
                    Text("Action:")
                        .foregroundStyle(Color.offWhite)
                    
                    VStack(alignment: .center) {
                        Text("Add to Available")
                            .font(.headline)
                            .foregroundStyle(Color.offWhite)
                    }
                }
            }
            
            HStack {
                Button {
                    if quantity > 0 {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                Text("\(quantity)")
                    .font(.largeTitle)
                    .foregroundStyle(Color.offWhite)
                    .padding()
                
                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            
            if !isDamaged {
                Button {
                    showTransferPicker.toggle()
                } label: {
                    Image(systemName: "paperplane.circle")
                        .font(.title)
                        .foregroundColor(.cyan)
                }
            }
            
            if showTransferPicker {
                Section("Select Destination Site") {
                    Picker("Site", selection: $selectedSite) {
                        ForEach(availableSites, id: \.id) { site in
                            Text(site.name).tag(site as Site?)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
            }
            
            Button {
                
                if !showTransferPicker {
                    if isDamaged {
                        selectedAction = .remove
                        quantity = -quantity
                        
                    } else {
                        selectedAction = .add
                    }
                    
                    viewModel.updateItemQuantity(site: site, itemId: itemID, change: quantity, type: selectedAction.rawValue, notes: "\(selectedAction) \(quantity) of \(itemID)", userId: viewModel.currentUser, isDamaged: isDamaged)
                    
                    quantity = 0
                }
            } label: {
                if !showTransferPicker {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.deepBlue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.neonGreen)
                        .cornerRadius(10)
                } else {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.offWhite)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
            }
            
            Button {
                if selectedSite != nil && quantity > 0 {
                    showTransferSiteAlert = true
                }
            } label: {
                
                if !showTransferPicker || selectedSite == nil || quantity <= 0 {
                    Text("Transfer to Another Site")
                        .font(.headline)
                        .foregroundColor(.offWhite)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                } else {
                    Text("Transfer to Another Site")
                        .font(.headline)
                        .foregroundColor(.deepBlue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.neonGreen)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.appBackgroundColor)).ignoresSafeArea()
        .navigationTitle("Edit Item")
        .task {
            await loadAvailableSites()
        }
        .alert(isPresented: $showTransferSiteAlert){
            Alert(
                title: Text("Transfer Item(s)"),
                message: Text("Are you sure you want to transfer \(itemID) to \(selectedSite?.name ?? "No Site Selected")"),
                primaryButton: .destructive(Text("Transfer")) {
                    Task {
                        if let selectedSite = selectedSite {
                            try await viewModel.transferItems(itemID: itemID, quantity: quantity, from: site, to: selectedSite, itemName: itemID)
                        }
                    }
                },
                secondaryButton: .cancel()
            )
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
            print("Failed to load sites: \(error.localizedDescription)")
        }
    }
    
}

#Preview {
    ItemDetailView(itemID: "reagajner", quantity: 2, viewModel: SitesViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), isDamaged: .constant(false))
}
