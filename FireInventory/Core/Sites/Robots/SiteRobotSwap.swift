//
//  SiteRobotSwap.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/13/24.
//

import SwiftUI

struct SiteRobotSwap: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSiteId: String? = nil
    @State private var availableSites: [Site] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let robotID: String
    let currentSiteId: String
    @ObservedObject var viewModel: RobotsViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Select New Site")) {
                    Picker("Available Sites", selection: $selectedSiteId) {
                        ForEach(availableSites, id: \.id) { site in
                            Text(site.name).tag(site.id as String?)
                        }
                    }
                }
            }
            .navigationTitle("Swap Robot Site")
            .toolbar {
                Button("Swap") {
                    guard let newSiteId = selectedSiteId else {
                        alertMessage = "Please select a site."
                        showAlert = true
                        return
                    }
                    
                    Task {
                        do {
                            try await viewModel.siteRobotSwap(from: currentSiteId, to: newSiteId, robotID: robotID)
                            presentationMode.wrappedValue.dismiss()

                        } catch {
                            alertMessage = "Failed to swap robot: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }
            .task {
                await loadAvailableSites()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadAvailableSites() async {
        do {
            let sites = try await SitesManager.shared.getAvailableSites(for: AuthenticationManager.shared.getCurrentUserId() ?? "unknown", excluding: currentSiteId)
            availableSites = sites
        } catch {
            alertMessage = "Failed to load sites: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    SiteRobotSwap(robotID: "klanrglevrn", currentSiteId: "ufsgbverbjv", viewModel: RobotsViewModel())
}
