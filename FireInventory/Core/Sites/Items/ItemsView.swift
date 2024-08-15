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
    @ObservedObject private var stockUpdateViewModel = StockUpdateViewModel()
    @ObservedObject private var deletedItemUpdateViewModel = DeletedItemUpdateViewModel()
    @State private var showPopup = false
    @State private var transferPresented = false
    @State private var showDamagedPopup = false

    var body: some View {
        NavigationStack {
            Section("Available"){
                List {
                    ForEach(site.items.keys.sorted(), id: \.self) { itemID in
                        HStack {
                            Text(viewModel.getItemName(by: itemID))
                            Spacer()
                            Text("Quantity: \(site.items[itemID] ?? 0)")
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            Section("Damaged") {
                List {
                    ForEach(site.damagedItems.keys.sorted(), id: \.self) { itemID in
                        HStack {
                            Text(viewModel.getItemName(by: itemID))
                            Spacer()
                            Text("Quantity: \(site.damagedItems[itemID] ?? 0)")
                        }
                    }
                }
                .listStyle(.plain)
            }
            Spacer()
            
            HStack {
                Button {
                    stockUpdateViewModel.isPush = true
                    showPopup.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Spacer()
                
                Button {
                    stockUpdateViewModel.isPush = false
                    showPopup.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                
                Spacer()
                
                Button {
                    transferPresented.toggle()
                } label: {
                    Image(systemName: "paperplane")
                }
                
                Spacer()
                           
                Button {
                    deletedItemUpdateViewModel.isPush = true
                    showDamagedPopup.toggle()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.red)
                }
                
                Spacer()
                
                Button {
                    deletedItemUpdateViewModel.isPush = false
                    showDamagedPopup.toggle()
                } label: {
                    Image(systemName: "arrow.up.trash")
                        .foregroundStyle(Color.red)
                }
            }
            .padding()
            .navigationTitle("Items")
            .sheet(isPresented: $showPopup) {
                StockUpdateView(viewModel: stockUpdateViewModel, siteViewModel: viewModel, site: site, isPresented: $showPopup)
            }
            .sheet(isPresented: $transferPresented){
                ItemTransferView(viewModel: viewModel, site: site, isPresented: $transferPresented)
            }
            .sheet(isPresented: $showDamagedPopup){
                DeletedItemUpdateView(viewModel: deletedItemUpdateViewModel, siteViewModel: viewModel, site: site, isPresented: $showDamagedPopup)
            }
        }
    }
}

#Preview {
    ItemsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: SitesViewModel())
}
