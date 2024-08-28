//
//  SwapRobotView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/4/24.
//

import SwiftUI

struct SwapRobotView: View {
    
    @Binding var selectedRobot: String?
    @Binding var position: PartPosition
    @Binding var isPresented: Bool
    let cart: Cart
    let viewModel: CartViewModel
    let site: Site
    @State private var swapNotes = ""
    @State private var showAlert = false
    @State private var availableRobots: [Robot] = []
    
    var newRobots: [Robot] {
        availableRobots.filter { $0.health == .new }
    }
    
    var refurbishedRobots: [Robot] {
        availableRobots.filter { $0.health == .refurbished }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundColor.ignoresSafeArea()
            
                Form {
                    Text("\(position.rawValue) Swap")
                        .font(.headline)
                        .foregroundStyle(Color.offWhite)
                        .listRowBackground(Color.deepBlue)
                    
                    Section("Reason for swap"){
                        TextEditor(text: $swapNotes)
                            .foregroundStyle(Color.offWhite)
                    }
                    .foregroundStyle(Color.neonGreen)
                    .listRowBackground(Color.deepBlue)
                    
                    if !newRobots.isEmpty {
                        Section("New Robots"){
                            ForEach(newRobots) { robot in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(robot.serialNumber)
                                            .foregroundStyle(Color.offWhite)
                                            .font(.headline)
                                        Text("G\(robot.version.rawValue)")
                                            .foregroundStyle(Color.offWhite)
                                            .font(.subheadline)
                                            .opacity(0.4)
                                    }
                                    Spacer()
                                    Button("Select") {
                                        if swapNotes.isEmpty {
                                            showAlert = true
                                        } else{
                                            Task {
                                                try await viewModel.swapRobot(in: cart, for: position, with: robot.serialNumber, from: site, notes: swapNotes)
                                                selectedRobot = robot.serialNumber
                                                isPresented = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .foregroundStyle(Color.neonGreen)
                        .listRowBackground(Color.deepBlue)
                    }
                    
                    if !refurbishedRobots.isEmpty {
                        Section("Refurbished Robots"){
                            ForEach(refurbishedRobots) { robot in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(robot.serialNumber)
                                            .foregroundStyle(Color.offWhite)
                                            .font(.headline)
                                        Text("G\(robot.version.rawValue)")
                                            .foregroundStyle(Color.offWhite)
                                            .font(.subheadline)
                                            .opacity(0.4)
                                    }
                                    Spacer()
                                    Button("Select") {
                                        if swapNotes.isEmpty {
                                            showAlert = true
                                        } else {
                                            Task {
                                                try await viewModel.swapRobot(in: cart, for: position, with: robot.serialNumber, from: site, notes: swapNotes)
                                                selectedRobot = robot.serialNumber
                                                await loadAvailableRobots()
                                                isPresented = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .foregroundStyle(Color.neonGreen)
                        .listRowBackground(Color.deepBlue)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackgroundColor.ignoresSafeArea())
            .task {
                print("swap view \(position)")
                await loadAvailableRobots()
            }
            .onDisappear {
                Task {
                    // Refresh robots in the view model
                    try? await viewModel.getAllRobots(for: site.id)
                }
            }
            .alert("Missing Field", isPresented: $showAlert) {
                Button("OK", role: .cancel){ }
            } message: {
                Text("Please fill the reason for robot swap")
            }
        }
        .padding()
    }
    
    private func loadAvailableRobots() async {
        availableRobots = await viewModel.getAvailableRobots(for: position, currentRobotSerial: selectedRobot)
        print("Loaded robots for position: \(position), available robots: \(availableRobots)")
    }
}

#Preview {
    SwapRobotView(selectedRobot: .constant("fdkngs;klm"), position: .constant(.BL), isPresented: .constant(false), cart: Cart(name: "rgnmrl;f"), viewModel: CartViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]))
}
