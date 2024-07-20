//
//  ItemsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/12/24.
//

import SwiftUI

@MainActor
final class ItemsViewModel: ObservableObject {
    
    @Published private(set) var items: [Item] = []
    
    func getAllItems() async throws {
        self.items = try await ItemsManager.shared.getAllItems()
    }
}



struct ItemsView: View {
    
    @StateObject private var viewModel = ItemsViewModel()
    
    var body: some View {
        List{
            ForEach(viewModel.items) { item in
                Text(item.itemName)
            }
        }
        .navigationTitle("Items")
        .task {
            try? await viewModel.getAllItems()
        }
    }
}

#Preview {
    NavigationStack {
        ItemsView()
    }
}
