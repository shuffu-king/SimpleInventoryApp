//
//  EditRobotView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/5/24.
//

import SwiftUI

struct EditRobotView: View {
    @Binding var robot: Robot
    let site: Site
    @ObservedObject var viewModel: RobotsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var showChangeWheelAlert = false
    @State private var robotNotes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Serial Number")
                    .foregroundColor(.neonGreen)) {
                        Text(robot.serialNumber)
                            .foregroundColor(.offWhite)
                    }
                    .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Position")
                    .foregroundColor(.neonGreen)) {
                        Text(robot.position.rawValue)
                            .foregroundColor(.offWhite)
                    }
                    .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Version")
                    .foregroundColor(.neonGreen)) {
                        Text(robot.version.rawValue)
                            .foregroundColor(.offWhite)
                    }
                    .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Health")
                    .foregroundColor(.neonGreen)) {
                        Picker("Health", selection: $robot.health) {
                            ForEach(RobotHealth.allCases, id: \.self) { health in
                                Text(health.rawValue).tag(health)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .listRowBackground(Color.deepBlue)
                
                Section(header: Text("Mecanum Type")
                    .foregroundColor(.neonGreen)) {
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
                
                Section(header: Text("Notes")
                    .foregroundColor(.neonGreen)) {
                        TextEditor(text: $robotNotes)
                            .frame(height: 100)
                            .background(Color.deepBlue)
                            .foregroundColor(.offWhite)
                    }
                    .listRowBackground(Color.deepBlue)
                
                Button(action: {
                    showChangeWheelAlert.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text("Replace Mecanum")
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
                
                if !(robot.rsosFinished ?? false)  {
                    Button(action: {
                        Task  {
                            try await viewModel.completeWheelRSOs(robot: robot, site: site)
                        }
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        HStack {
                            Spacer()
                            Text("Complete RSOs")
                                .font(.headline)
                                .foregroundColor(.deepBlue)
                            Spacer()
                        }
                        .padding()
                        .background(Color.neonGreen)
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.appBackgroundColor)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackgroundColor.ignoresSafeArea())
            .navigationTitle("Update Wheel")
            .toolbar {
                Button("Save") {
                    robot.notes = robotNotes
                    
                    if robotNotes.isEmpty {
                        showAlert = true
                    } else {
                        Task {
                            try await viewModel.updateRobot(from: site, robot: robot)
                            try await viewModel.getAllRobots(for: site.id)
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.neonGreen)
            }
            .toolbarBackground(Color.deepBlue, for: .navigationBar) // Set toolbar background
            .toolbarBackground(.visible, for: .navigationBar) // Ensure toolbar background is visible
            .alert("One or more fields missing", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert(isPresented: $showChangeWheelAlert) {
                Alert(
                    title: Text("Replace Mecanum"),
                    message: Text("Are you sure you want to replace this mecanum? This action cannot be undone."),
                    primaryButton: .destructive(Text("Replace")) {
                        Task {
                            try await viewModel.changeRobotWheel(robot: robot, site: site)
                            try await viewModel.getAllRobots(for: site.id)
                        }
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

#Preview {
    EditRobotView(robot: .constant(Robot(serialNumber: "iodfjwingor", position: .TL, version: .G22, health: .damaged, siteID: "grnirenogpei")), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["asdfghj"]), viewModel: RobotsViewModel())
}
