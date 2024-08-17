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
    @State private var showDeleteAlert = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Site ID: \(site.id)")
                .font(.headline)
            Text("Location: \(site.location)")
                .font(.subheadline)
                .opacity(0.7)
            
            NavigationLink {
                RobotsView(site: site)
            } label: {
                Text("Robots")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
            NavigationLink {
                CartsView(site: site)
            } label: {
                Text("Carts")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            NavigationLink {
                ItemsView(site: site, viewModel: viewModel)
            } label: {
                Text("Items")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
                
        }
        .padding()

        VStack(alignment: .center) {
            Button("Delete Site", role: .destructive){
                showDeleteAlert.toggle()
            }
        }
        .padding()
        .navigationTitle("\(site.name)")
        .alert(isPresented: $showDeleteAlert){
            Alert(
                title: Text("Delete Site"),
                message: Text("Are you sure you want to delete this site? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    Task {
                        do {
                            try await viewModel.deleteSite(site.id)
                        } catch {
                            print("Error deleting site: \(error)")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    NavigationStack {
        SiteStockView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: SitesViewModel())
    }
}
