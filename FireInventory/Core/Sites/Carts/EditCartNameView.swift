//
//  EditCartNameView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 9/16/24.
//

import SwiftUI

struct EditCartNameView: View {
    let site: Site
    let cart: Cart
    @State private var newName = ""
    @State private var showNameAlert = false
    @ObservedObject var viewModel: CartViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Section("Edit Cart Name") {
            TextField(cart.name, text: $newName)
                .padding()
        }
        
        Button {
            for newCart in viewModel.carts {
                if newName != cart.name && !newName.isEmpty && newCart.id == cart.id {
                    Task {
                        try await viewModel.updateCartName(cart: newCart, newName: newName, site: site)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        } label: {
            HStack {
                Text("Save")
            }
            .font(.headline)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.vertical, 10)
        
        .alert("Cart name already taken", isPresented: $showNameAlert) {
            Button("OK", role: .cancel){ }
        }
        
    }
    
}

#Preview {
    EditCartNameView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), cart: Cart(id: "gnsignlse", name: "test cart"), viewModel: CartViewModel())
}
