//
//  EditRobotView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/5/24.
//

import SwiftUI

struct EditRobotView: View {
    @State var robot: Robot
    let siteId: String
    @ObservedObject var viewModel: RobotsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var healthSelection: RobotHealth = .new
    @State private var showAlert = false
    @State private var robotNotes = ""
    
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
                    Picker("Health", selection: $healthSelection) {
                        ForEach(RobotHealth.allCases, id: \.self){ health in
                            Text(health.rawValue).tag(health)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Notes") {
                    TextEditor(text: $robotNotes)
                        .frame(height: 100)
                }
                
                Button("Change Wheel") {
                    
                }
                .buttonBorderShape(.roundedRectangle(radius: 15))
            }
            .navigationTitle("Edit Robot")
            .toolbar {
                Button("Save") {
                    Task {
                        if (robot.health == healthSelection) || (robotNotes.isEmpty){
                            showAlert = true
                        } else {
                            robot.health = healthSelection
                            robot.notes = robotNotes
                            try await viewModel.updateRobot(from: siteId, robot: robot)
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .alert("One or more fields missing", isPresented: $showAlert) {
                Button("OK", role: .cancel){ }
            }
        }
    }
}

#Preview {
    EditRobotView(robot: Robot(serialNumber: "iodfjwingor", position: .TL, version: .G22, health: .damaged, siteID: "grnirenogpei"), siteId: "ougihneoignwe", viewModel: RobotsViewModel())
}
