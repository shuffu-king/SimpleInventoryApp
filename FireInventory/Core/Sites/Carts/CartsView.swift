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
    
    var body: some View {
        VStack {
            List(viewModel.carts){ cart in
                VStack(alignment: .leading){
                    HStack {
                        Text(cart.name)
                        Spacer ()
                        Button {
                            viewModel.toggleCartExpansion(cartId: cart.id)
                        } label: {
                            Image(systemName: viewModel.expandedCartID == cart.id ? "chevron.up" : "chevron.down")
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    if viewModel.expandedCartID == cart.id {
                        VStack(alignment: .leading) {
                            if let password = cart.password {
                                Text(password)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else  {
                                Text("No password")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Text("Robots: \(cart.robots.count)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
            }
            .listStyle(PlainListStyle())
            .scrollIndicators(.visible)
            .navigationTitle("Carts")
            .task {
                do {
                    try await viewModel.getAllCarts(for: site.id)
                } catch {
                    print("Failed to fetch carts: \(error.localizedDescription)")
                }
            }
            
            Form {
                Section("Add new cart"){
                    TextField("Cart Name", text: $viewModel.newCartName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Password (Optional)", text: $viewModel.newCartPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        
    }
}

//#Preview {
//    CartsView(site: Site(id: "test", name: "test name", location: "test location", items: ["item1": 1], userIDs: ["user1"], robots: [], carts: [Cart(id: "cart1", name: "Cart 1", password: "1234", robots: [])]))
//}
