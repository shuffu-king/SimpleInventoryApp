//
//  InUseItemDetailView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/24/24.
//

import SwiftUI

struct InUseItemDetailView: View {
    
    @State var itemID: String
    @State var quantity: Int = 0
    @ObservedObject var viewModel: SitesViewModel
    @State private var selectedAction: Action = .add
    
    let site: Site
    
    enum Action: String, CaseIterable, Identifiable {
        case add = "Add"
        case remove = "Remove"
        
        var id: String { self.rawValue }
    }
    
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Current Item: \(itemID)")
                .font(.headline)
                .foregroundStyle(Color.offWhite)

            Text("\(site.inUseItems[itemID] ?? 0)")
                .font(.title)
                .foregroundStyle(Color.offWhite)

            Picker("Add or Remove", selection: $selectedAction) {
                ForEach(Action.allCases) { action in
                    Text(action.rawValue).tag(action)
                        .foregroundStyle(Color.offWhite)
                }
                
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                Button {
                    if quantity > 0 {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                Text("\(quantity)")
                    .font(.largeTitle)
                    .foregroundStyle(Color.offWhite)
                    .padding()
                
                Button{
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            
            Button {
                Task {
                   try await viewModel.updateInUseItemQuantity(site: site, itemId: itemID, change: quantity, type: selectedAction.rawValue, notes: "\(selectedAction) \(quantity) of \(itemID)", userId: viewModel.currentUser)
                    quantity = 0
                    await Task.sleep(500_000_000) // 0.5 seconds delay
                }
                
            } label: {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.deepBlue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.neonGreen)
                    .cornerRadius(10)
                
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(Color.appBackgroundColor)).ignoresSafeArea()
        .navigationTitle("Edit Item")
        .onDisappear {
            Task {
                try await SitesManager.shared.getAllSites(for: site.id)
            }
        }
    }
}

#Preview {
    InUseItemDetailView(itemID: "rhgbakrj", viewModel: SitesViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]))
}
