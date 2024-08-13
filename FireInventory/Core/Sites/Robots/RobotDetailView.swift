//
//  RobotDetailView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/5/24.
//

import SwiftUI

struct RobotDetailView: View {
    @State var robot: Robot
    let siteId: String
    @ObservedObject var viewModel: RobotsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isSiteSwapRobotViewPresented = false
    @State private var isEditable = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Serial Number"){
                    Text(robot.serialNumber)
                }
                
                Section("Position"){
                    Text(robot.position.rawValue)
                }
                
                Section("Version"){
                    Text(robot.version.rawValue)
                }
                
                Section("Health"){
                    Text(robot.health.rawValue)
                }
                
                Section("Notes") {
                    Text(robot.notes ?? "N/A")
                }
                
                Button("Change Site"){
                    isSiteSwapRobotViewPresented = true
                }
                .foregroundStyle(.orange)
            }
            .navigationTitle("Robot")
            .toolbar {
                Button("Edit"){
                    isEditable.toggle()
                }
            }
            .sheet(isPresented: $isEditable){
                EditRobotView(robot: robot, siteId: siteId, viewModel: viewModel)
            }
            .sheet(isPresented: $isSiteSwapRobotViewPresented) {
                SiteRobotSwap(robotID: robot.id, currentSiteId: siteId, viewModel: viewModel)
            }
        }
    }
}

#Preview {
    RobotDetailView(robot: Robot(serialNumber: "rjghiuesrjghkaes", position: .BL, version: .G21, health: .refurbished, siteID: "fgsugjnvalwk", notes: "gaskfjgvbas"), siteId: "gjsbgfkjbav", viewModel: RobotsViewModel())
}
