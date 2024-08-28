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
        VStack {
            ScrollView {
                ForEach(viewModel.sites) { site in
                    NavigationLink {
                        SiteStockView(site: site, viewModel: viewModel)
                    } label: {
                        ZStack(alignment: .leading) {
                            Color.deepBlue
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading) {
                                Text(site.name)
                                    .font(.headline)
                                    .foregroundStyle(Color.offWhite)

                                Text(site.location)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.offWhite)
                                    .opacity(0.7)
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.appBackgroundColor))
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
