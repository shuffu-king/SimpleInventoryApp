//
//  ItemsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/13/24.
//

import SwiftUI

struct ItemsView: View {
    let site: Site
    @ObservedObject var viewModel: SitesViewModel
    
    var totalAvailableItems: Int {
        site.items.values.reduce(0, +)
    }
    
    var totalDamagedItems: Int {
        site.damagedItems.values.reduce(0, +)
    }
    
    var totalInUseItems: Int {
        site.inUseItems.values.reduce(0, +)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack(alignment: .center, spacing: 20) {
                    Text("(Total: \(totalDamagedItems + totalAvailableItems + totalInUseItems))")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("In-Use Items (Total: \(totalInUseItems))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.offWhite)
                            .padding(.horizontal)
                        
                        ForEach(site.inUseItems.keys.sorted(), id: \.self) { itemID in
                            NavigationLink(destination: InUseItemDetailView(itemID: itemID, viewModel: viewModel, site: site)){
                                ZStack {
                                    Color.deepBlue
                                        .cornerRadius(12)
                                    
                                    HStack {
                                        Text(itemID)
                                            .font(.headline)
                                            .foregroundStyle(Color.offWhite)
                                        Spacer()
                                        Text("Quantity: \(site.inUseItems[itemID] ?? 0)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.offWhite)
                                    }
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Available Items Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Available Items (Total: \(totalAvailableItems))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.offWhite)
                            .padding(.horizontal)
                        
                        ForEach(site.items.keys.sorted(), id: \.self) { itemID in
                            NavigationLink(destination: ItemDetailView(itemID: itemID, viewModel: viewModel, site: site, isDamaged: .constant(false))){
                                ZStack {
                                    Color.deepBlue
                                        .cornerRadius(12)
                                    
                                    HStack {
                                        Text(itemID)
                                            .font(.headline)
                                            .foregroundStyle(Color.offWhite)
                                        Spacer()
                                        Text("Quantity: \(site.items[itemID] ?? 0)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.offWhite)
                                    }
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Damaged Items Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Damaged Items (Total: \(totalDamagedItems))")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.offWhite)
                            .padding(.horizontal)
                        
                        ForEach(site.damagedItems.keys.sorted(), id: \.self) { itemID in
                            NavigationLink(destination: ItemDetailView(itemID: itemID, viewModel: viewModel, site: site, isDamaged: .constant(true))){
                                
                                ZStack {
                                    Color.deepBlue
                                        .cornerRadius(12)
                                    
                                    HStack {
                                        Text(itemID)
                                            .font(.headline)
                                            .foregroundStyle(Color.offWhite)
                                        Spacer()
                                        Text("Quantity: \(site.damagedItems[itemID] ?? 0)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.offWhite)
                                    }
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                    }
                    .padding(.vertical, 10)
                    
                    // Action Buttons
                    //                HStack {
                    //                    Button {
                    //                        stockUpdateViewModel.isPush = true
                    //                        showPopup.toggle()
                    //                    } label: {
                    //                        Image(systemName: "plus")
                    //                            .font(.title)
                    //                            .padding()
                    //                            .background(Color.neonGreen)
                    //                            .foregroundStyle(Color.deepBlue)
                    //                            .cornerRadius(12)
                    //                    }
                    //
                    //                    Spacer()
                    //
                    //                    Button {
                    //                        stockUpdateViewModel.isPush = false
                    //                        showPopup.toggle()
                    //                    } label: {
                    //                        Image(systemName: "minus")
                    //                            .font(.title)
                    //                            .padding()
                    //                            .background(Color.neonGreen)
                    //                            .foregroundStyle(Color.deepBlue)
                    //                            .cornerRadius(12)
                    //                    }
                    //
                    //                    Spacer()
                    //
                    //                    Button {
                    //                        transferPresented = true
                    //                    } label: {
                    //                        Image(systemName: "paperplane")
                    //                            .font(.title)
                    //                            .padding()
                    //                            .background(Color.mint)
                    //                            .foregroundStyle(Color.deepBlue)
                    //                            .cornerRadius(12)
                    //                    }
                    //
                    //                    Spacer()
                    //
                    //                    Button {
                    //                        deletedItemUpdateViewModel.isPush = false
                    //                        showDamagedPopup.toggle()
                    //                    } label: {
                    //                        Image(systemName: "minus")
                    //                            .font(.title)
                    //                            .padding()
                    //                            .background(Color.red)
                    //                            .foregroundStyle(Color.offWhite)
                    //                            .cornerRadius(12)
                    //                    }
                    //
                    //                    Spacer()
                    //
                    //                    Button {
                    //                        deletedItemUpdateViewModel.isPush = true
                    //                        showDamagedPopup.toggle()
                    //                    } label: {
                    //                        Image(systemName: "plus")
                    //                            .font(.title)
                    //                            .padding()
                    //                            .background(Color.red)
                    //                            .foregroundStyle(Color.offWhite)
                    //                            .cornerRadius(12)
                    //                    }
                    //                }
                    //                .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(Color(Color.appBackgroundColor))
        .navigationTitle("Items")
//        .sheet(isPresented: $showPopup) {
//            StockUpdateView(viewModel: stockUpdateViewModel, siteViewModel: viewModel, site: site, isPresented: $showPopup)
//        }
//        .sheet(isPresented: $transferPresented){
//            ItemTransferView(viewModel: viewModel, site: site, transferPresented: $transferPresented)
//        }
//        .sheet(isPresented: $showDamagedPopup){
//            DeletedItemUpdateView(viewModel: deletedItemUpdateViewModel, siteViewModel: viewModel, site: site, isPresented: $showDamagedPopup)
//        }
        .onAppear {
            Task {
                try await SitesManager.shared.refreshAllItems(for: site.id)
            }
        }
    }
}

#Preview {
    ItemsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: SitesViewModel())
}

