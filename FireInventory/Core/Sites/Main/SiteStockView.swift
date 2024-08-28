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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Site Information
                VStack(alignment: .leading, spacing: 5) {
                    Text(site.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.offWhite)
                    
                    Text("Location: \(site.location)")
                        .font(.subheadline)
                        .foregroundStyle(Color.offWhite)
                        .opacity(0.6)
                    
                    Text("Site ID: \(site.id)")
                        .font(.subheadline)
                        .foregroundStyle(Color.offWhite)
                        .opacity(0.6)
                }
                .padding()
                .background(Color(Color.deepBlue))
                .cornerRadius(12)
                .frame(maxWidth: .infinity)
                
                // Navigation Links
                VStack(spacing: 15) {
                    NavigationLink {
                        RobotsView(site: site)
                    } label: {
                        Label("Wheels", systemImage: "transmission")
                            .font(.headline)
                            .foregroundStyle(Color.deepBlue)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.neonGreen)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink {
                        CartsView(site: site)
                    } label: {
                        Label("Carts", systemImage: "cart")
                            .font(.headline)
                            .foregroundStyle(Color.deepBlue)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.neonGreen)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink {
                        ItemsView(site: site, viewModel: viewModel)
                    } label: {
                        Label("Items", systemImage: "cube.box.fill")
                            .font(.headline)
                            .foregroundStyle(Color.deepBlue)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.neonGreen)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Transactions Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Transactions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .foregroundStyle(Color.offWhite)
                    
                    ScrollView {
                        ForEach(viewModel.transactions) { transaction in
                            ZStack(alignment: .leading) {
                                Color.deepBlue
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    if transaction.entityType == "site" {
                                        Text("Site ID: \(transaction.siteId)")
                                            .font(.headline)
                                    } else {
                                        Text("Entity ID: \(transaction.entityId)")
                                            .font(.headline)
                                        
                                        Text("Entity type: \(transaction.entityType)")
                                            .font(.headline)
                                    }
                                    
                                    Text("Action: \(transaction.action)")
                                        .font(.subheadline)
                                    
                                    Text("User: \(transaction.userId)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Date: \(transaction.timestamp.dateValue().formatted(date: .abbreviated, time: .shortened))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxHeight: 300)
                }
            }
            .padding()
        }
        .background(Color(Color.appBackgroundColor))
        .onAppear {
            Task {
                try await viewModel.fetchTransactions(for: site.name)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SiteStockView(site: Site(id: "ugbslkes", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: SitesViewModel())
    }
}
