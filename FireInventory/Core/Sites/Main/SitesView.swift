//
//  SitesView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import SwiftUI

struct SitesView: View {
    
    @StateObject private var viewModel = SitesViewModel()
    @State private var showAddView = false
    
    var body: some View {
        List {
            ForEach(viewModel.sites) { site in
                
                NavigationLink {
                    SiteStockView(site: site, viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading) {
                        Text(site.name)
                        Text(site.location)
                            .opacity(0.7)
                        Text("Site ID: \(site.id)")
                            .opacity(0.4)
                    }
                }
            }
        }
        .navigationTitle("Sites")
        .task {
            try? await viewModel.getAllSites()
            try? await viewModel.getAllItems()
        }
        .toolbar {
            Button("Add button", systemImage: "plus") {
                showAddView.toggle()
            }
        }
        .sheet(isPresented: $showAddView){
            AddSiteView(viewModel: viewModel, showAddView: $showAddView)
        }
        
    }
}

#Preview {
    NavigationStack {
        SitesView()
    }
}
