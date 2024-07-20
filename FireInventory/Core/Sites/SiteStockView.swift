//
//  SiteStockView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import SwiftUI



struct SiteStockView: View {
    
    let site: Site
    @ObservedObject var viewModel: SitesViewModel
    @ObservedObject private var stockUpdateViewModel = StockUpdateViewModel()
    @State private var showPopup = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Site ID: \(site.id)")
                .font(.headline)
            Text("Location: \(site.location)")
                .font(.subheadline)
                .opacity(0.7)
            Text("Items:")
                .font(.headline)
            
            List {
                ForEach(site.items.keys.sorted(), id: \.self) { itemID in
                    HStack {
                        Text(viewModel.getItemName(by: itemID))
                        Spacer()
                        Text("Quantity: \(site.items[itemID] ?? 0)")
                    }
                }
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
                 
            }
            
            
            
        }
        .padding()
        .navigationTitle("\(site.name)")
        .sheet(isPresented: $showPopup) {
            StockUpdateView(viewModel: stockUpdateViewModel, siteViewModel: viewModel, site: site, isPresented: $showPopup)
        }
    }
}

#Preview {
    NavigationStack {
        SiteStockView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], userIDs: ["test_users"]), viewModel: SitesViewModel())
    }
}
