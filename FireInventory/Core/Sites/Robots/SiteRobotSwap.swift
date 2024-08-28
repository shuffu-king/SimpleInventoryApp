//
//  SiteRobotSwap.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/13/24.
//

import SwiftUI

struct SiteRobotSwap: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSite: Site? = nil
    @State private var availableSites: [Site] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let robotID: String
    let currentSite: Site
    @ObservedObject var viewModel: RobotsViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select New Site") {
                    Picker("Available Sites", selection: $selectedSite) {
                        ForEach(availableSites, id: \.id) { site in
                            Text(site.name).tag(site as Site?)
                                .foregroundStyle(Color.offWhite)
                        }
                    }
                    .foregroundStyle(Color.offWhite)
                }
                .listRowBackground(Color.deepBlue.ignoresSafeArea())
            }
            .background(Color.appBackgroundColor.ignoresSafeArea())
            .navigationTitle("Swap Robot Site")
            .toolbar {
                Button("Swap") {
                    guard let newSite = selectedSite else {
                        alertMessage = "Please select a site."
                        showAlert = true
                        return
                    }
                    
                    Task {
                        do {
                            try await viewModel.siteRobotSwap(from: currentSite, to: newSite, robotID: robotID)
                            presentationMode.wrappedValue.dismiss()

                        } catch {
                            alertMessage = "Failed to swap robot: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }
            .onAppear {
                
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
            let sites = try await SitesManager.shared.getAvailableSites(for: AuthenticationManager.shared.getCurrentUserId() ?? "unknown", excluding: currentSite.id)
            availableSites = sites
            
            if let firstSite = availableSites.first {
                selectedSite = firstSite
            }
        } catch {
            alertMessage = "Failed to load sites: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    SiteRobotSwap(robotID: "klanrglevrn", currentSite: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["asdfghj"]), viewModel: RobotsViewModel())
}
