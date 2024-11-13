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
    
    @State private var searchQuery = ""
    @State private var showScanner = false
    @State private var selectedHealth: RobotHealth? = nil
    @State private var selectedVersion: RobotVersion? = nil
    @State private var selectedRSOsCompleted: Bool? = nil
    
    var filteredRobots: [Robot] {
        availableRobots.filter { robot in
            let matchesHealth = selectedHealth == nil || robot.health == selectedHealth
            let matchesVersion = selectedVersion == nil || robot.version == selectedVersion
            let matchesSearchText = searchQuery.isEmpty || robot.serialNumber.lowercased().contains(searchQuery.lowercased())
            
            let isRsosFinished = robot.rsosFinished ?? false
            let matchesRSOS = selectedRSOsCompleted == nil || isRsosFinished == selectedRSOsCompleted
            
            return matchesHealth && matchesVersion && matchesSearchText && matchesRSOS
        }
    }
    
    var newRobots: [Robot] {
        availableRobots.filter { $0.health == .new }
    }
    
    var refurbishedRobots: [Robot] {
        availableRobots.filter { $0.health == .refurbished }
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                    
                TextField("Enter Reason Here", text: $swapNotes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Section {
                    HStack{
                        TextField("Search by Serial Number", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button {
                            if !showScanner {
                                showScanner = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .foregroundStyle(Color.neonGreen)
                            }
                        }
                    }
                    .padding()
                    
                    Section {
                        HStack() {
                            Picker("", selection: $selectedHealth){
                                Text("Health").tag(RobotHealth?.none)
                                ForEach(RobotHealth.allCases, id: \.self){ health in
                                    if health != .damaged {
                                        Text(health.rawValue).tag(RobotHealth?.some(health))
                                    }
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("", selection: $selectedVersion){
                                Text("Version").tag(RobotVersion?.none)
                                ForEach(RobotVersion.allCases, id: \.self){ version in
                                    Text(version.rawValue).tag(RobotVersion?.some(version))
                                    
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("Select RSOs", selection: $selectedRSOsCompleted) {
                                // If RSOs, should show all robots
                                Text("RSOs").tag(Bool?.none)
                                Text("Yes").tag(Bool?.some(true))
                                Text("No").tag(Bool?.some(false))
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Text("Total: \(filteredRobots.count)")
                        }
                    }
                }
                
                
                List {
                    ForEach(filteredRobots) { robot in
                        
                        if robot.health != .damaged {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(robot.serialNumber)
                                        .foregroundStyle(Color.offWhite)
                                        .font(.headline)
                                    Text(robot.health.rawValue)
                                        .foregroundStyle(Color.offWhite)
                                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                    Text("G\(robot.version.rawValue)")
                                        .foregroundStyle(Color.offWhite)
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
                    .listRowBackground(Color.deepBlue)
                }
            }
            .navigationTitle("Select \(position.rawValue)")
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
        .sheet(isPresented: $showScanner) {
            QRScannerView(scannedSN: $searchQuery)
        }
    }
    
    private func loadAvailableRobots() async {
        availableRobots = viewModel.getAvailableRobots(for: position, currentRobotSerial: selectedRobot)
        print("Loaded robots for position: \(position), available robots: \(availableRobots)")
    }
}

#Preview {
    SwapRobotView(selectedRobot: .constant("fdkngs;klm"), position: .constant(.BL), isPresented: .constant(false), cart: Cart(id: "ngklnrsglk", name: "rgnmrl;f"), viewModel: CartViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]))
}
