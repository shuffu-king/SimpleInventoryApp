//
//  DeletedItemUpdateView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/15/24.
//

import SwiftUI

@MainActor
final class DeletedItemUpdateViewModel: ObservableObject {
    @Published var selectedItemID = ""
    @Published var quantity = 1
    @Published var isPush = true
    @Published var notes = ""
    
    func updateItemQuantity(site: Site, viewModel: SitesViewModel) {
        guard !selectedItemID.isEmpty else { return }
        
        let itemName = selectedItemID
        
        let change = isPush ? quantity : -quantity
        viewModel.updateItemQuantity(site: site, itemId: selectedItemID, change: change, type: isPush ? "Push" : "Pull", notes: "for item \(itemName)", userId: AuthenticationManager.shared.getCurrentUserId() ?? "unknown", isDamaged: true)
    }
}

struct DeletedItemUpdateView: View {
    
    @ObservedObject var viewModel: DeletedItemUpdateViewModel
    @ObservedObject var siteViewModel: SitesViewModel
    let site: Site
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Select Item", selection: $viewModel.selectedItemID) {
                    ForEach(site.items.keys.sorted(), id: \.self){ itemId in
                        Text(itemId).tag(itemId)
                    }
                }
                
                Stepper("Quantity: \(viewModel.quantity)", value: $viewModel.quantity, in: 1...50)
                                
                Button("Apply"){
                    viewModel.notes = "item name: \(viewModel.selectedItemID)"
                    viewModel.updateItemQuantity(site: site, viewModel: siteViewModel)
                    viewModel.selectedItemID = ""
                    viewModel.quantity = 1
                    viewModel.notes = ""
                    isPresented = false
                }
            }
            .onAppear{
                if viewModel.selectedItemID.isEmpty, let firstItemId = site.items.keys.sorted().first {
                    viewModel.selectedItemID = firstItemId
                }
            }
            .navigationTitle(viewModel.isPush ? "Push to Damaged" : "Pull from Damaged")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        viewModel.selectedItemID = ""
                        viewModel.quantity = 1
                        isPresented = false
                    }
                    
                }
            }
        }
    }
}

#Preview {
    DeletedItemUpdateView(viewModel: DeletedItemUpdateViewModel(), siteViewModel: SitesViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), isPresented: .constant(false))
}
