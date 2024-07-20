//
//  SitesView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/13/24.
//

import SwiftUI

struct SitesView: View {
    
    @StateObject private var viewModel = SitesViewModel()
    
    var body: some View {
        
        List{
            ForEach(viewModel.sites) { site in
                
                NavigationLink {
                    SiteStockView(site: site, viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Site ID: \(site.id)")
                        Text(site.name)
                        Text(site.location)
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
        
    }
}

#Preview {
    NavigationStack {
        SitesView()
    }
}
