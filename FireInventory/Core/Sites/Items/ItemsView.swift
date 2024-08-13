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
    @State private var showPopup = false
    
    var body: some View {
        NavigationStack {
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
            }
            .padding()
            .navigationTitle("Items")
            .sheet(isPresented: $showPopup) {
                StockUpdateView(viewModel: stockUpdateViewModel, siteViewModel: viewModel, site: site, isPresented: $showPopup)
            }
        }
    }
}

#Preview {
    ItemsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: SitesViewModel())
}
