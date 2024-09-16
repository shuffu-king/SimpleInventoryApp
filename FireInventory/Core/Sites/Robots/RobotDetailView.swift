//
//  RobotDetailView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/5/24.
//

import SwiftUI

struct RobotDetailView: View {
    @State var robot: Robot
    let site: Site
    @ObservedObject var viewModel: RobotsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isSiteSwapRobotViewPresented = false
    @State private var isEditable = false
    @State private var assignedCart: Cart?

    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Serial Number").foregroundColor(.neonGreen)) {
                    Text(robot.serialNumber)
                        .foregroundColor(.offWhite)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Site").foregroundColor(.neonGreen)) {
                    Text(site.name)
                        .foregroundColor(.offWhite)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Position").foregroundColor(.neonGreen)) {
                    Text(robot.position.rawValue)
                        .foregroundColor(.offWhite)
                        .background(Color.deepBlue)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Version").foregroundColor(.neonGreen)) {
                    Text(robot.version.rawValue)
                        .foregroundColor(.offWhite)
                        .background(Color.deepBlue)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Health").foregroundColor(.neonGreen)) {
                    Text(robot.health.rawValue)
                        .foregroundColor(.offWhite)
                        .background(Color.deepBlue)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Cart Assigned").foregroundColor(.neonGreen)) {
                    if let assignedCart = assignedCart {
                        Text(assignedCart.name)
                            .foregroundColor(.offWhite)
                    } else {
                        Text("Not assigned to any cart")
                            .foregroundColor(.offWhite)
                    }
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Notes").foregroundColor(.neonGreen)) {
                    Text(robot.notes ?? "N/A")
                        .foregroundColor(.offWhite)
                        .background(Color.deepBlue)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Mecanum Type").foregroundColor(.neonGreen)) {
                    Text(robot.wheelType)
                        .foregroundColor(.offWhite)
                    Text("Date last changed: \(robot.wheelInstallationDate?.formatted(date: .abbreviated, time: .shortened) ?? "None")")
                        .foregroundColor(.offWhite)
                }
                .listRowBackground(Color.deepBlue)
                
                Section(header: Text("RSO complete").foregroundColor(.neonGreen)) {
                    Text(robot.rsosFinished ?? false ? "Yes" : "No")
                            .foregroundColor(.offWhite)
                }
                .listRowBackground(Color.deepBlue)
                
                Button(action: {
                    isSiteSwapRobotViewPresented = true
                }) {
                    HStack {
                        Spacer()
                        Text("Change Site")
                            .font(.headline)
                            .foregroundColor(.deepBlue)
                        Spacer()
                    }
                    .padding()
                    .background(Color.neonGreen)
                    .cornerRadius(10)
                }
                .padding(.vertical)
                .listRowBackground(Color.appBackgroundColor)
                
            }
            .background(Color.appBackgroundColor.ignoresSafeArea())
            .toolbar {
                Button(action: {
                    isEditable.toggle()
                }) {
                    Text("Update")
                        .foregroundColor(.neonGreen)
                }
            }
            .toolbarBackground(Color.deepBlue, for: .navigationBar) // Set toolbar background
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $isEditable) {
                EditRobotView(robot: $robot, site: site, viewModel: viewModel)
                    .background(Color.appBackgroundColor)
            }
            .sheet(isPresented: $isSiteSwapRobotViewPresented) {
                SiteRobotSwap(robotID: robot.id, currentSite: site, viewModel: viewModel)
                    .background(Color.appBackgroundColor)
            }
            .task {
                try? await viewModel.getAllRobots(for: site.id)
                
                do {
                    assignedCart = try await viewModel.getCartForRobot(robotSerialNumber: robot.serialNumber, siteId: site.id)
                } catch {
                    print("Failed to get assigned cart: \(error)")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.appBackgroundColor)
    }
}

#Preview {
    RobotDetailView(robot: Robot(serialNumber: "rjghiuesrjghkaes", position: .BL, version: .G21, health: .refurbished, siteID: "fgsugjnvalwk", notes: "gaskfjgvbas"), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: RobotsViewModel())
}
