//
//  CartsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/30/24.
//

import SwiftUI

struct CartsView: View {
    
    let site: Site
    @StateObject private var viewModel = CartViewModel()
    @State private var showingAddCartView = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.carts) { cart in
                    NavigationLink {
                        CartDetailView(cart: cart, viewModel: viewModel, site: site)
                            .background(Color.appBackgroundColor.ignoresSafeArea())
                    } label: {
                        VStack {
                            Text(cart.name)
                                .font(.headline)
                                .foregroundStyle(Color.offWhite)
                        }
                        .padding()
                    }
                    .listRowBackground(Color.deepBlue)
                }
                .onDelete { IndexSet in
                    Task {
                        if let index = IndexSet.first {
                            let cart = viewModel.carts[index]
                            try await viewModel.deleteCart(for: site, cart: cart)
                        }
                    }
                }
            }
            .background(Color(Color.appBackgroundColor))
            .listStyle(PlainListStyle())
            .navigationTitle("Carts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddCartView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showingAddCartView){
                        AddCartView(viewModel: viewModel, site: site)
                            .background(Color.appBackgroundColor.ignoresSafeArea())
                    }
                }
            }
            .task {
                try? await viewModel.getAllCarts(for: site.id)
                try? await viewModel.getAllRobots(for: site.id)
            }
        }
    }
}

#Preview {
    CartsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]))
}

