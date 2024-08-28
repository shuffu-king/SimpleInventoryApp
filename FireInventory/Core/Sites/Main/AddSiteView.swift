//
//  AddSiteView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/16/24.
//

import SwiftUI

struct AddSiteView: View {
    
    @ObservedObject var viewModel: SitesViewModel
    @Binding var showAddView: Bool
    
    @State private var name = ""
    @State private var location = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Site details") {
                    TextField("Site Name", text: $name)
                        .autocapitalization(.words)
                    TextField("Site Location", text: $location)
                        .autocapitalization(.words)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Site")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveSite()
                        }
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddView = false
                    }
                }
                
            }
        }
        
    }
    
    func saveSite() async {
        do {
            let newSite = Site(id: UUID().uuidString, name: name, location: location,
                               items: ["Mecanum-TL-BR": 0, "Mecanum-TR-BL": 0, "Battery Charger": 0, "Charging station": 0],
                               damagedItems: ["Mecanum-TL-BR": 0, "Mecanum-TR-BL": 0, "Battery Charger": 0, "Charging station": 0], inUseItems: ["Mecanum-TL-BR": 0, "Mecanum-TR-BL": 0, "Battery Charger": 0, "Charging station": 0],
                               userIDs: [],
                               robotIDs: [])
            try await viewModel.addSite(newSite)
            showAddView = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
#Preview {
    AddSiteView(viewModel: SitesViewModel(), showAddView: .constant(true))
}
