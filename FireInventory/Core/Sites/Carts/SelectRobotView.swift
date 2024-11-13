//
//  SelectRobotView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/10/24.
//

import SwiftUI

struct SelectRobotView: View {
    @Binding var selectedRobot: Robot?
    let availableRobots: [Robot]
    @Binding var isPresented: Bool
    let position: PartPosition
    let viewModel: CartViewModel
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
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    
                    Spacer()
        
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
                                    selectedRobot = robot
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.deepBlue)
                }
            }
            .navigationTitle("Select \(position.rawValue)")
            .sheet(isPresented: $showScanner) {
                QRScannerView(scannedSN: $searchQuery)
            }
        }
        .background(Color.appBackgroundColor).ignoresSafeArea()
        .padding()
    }
}

#Preview {
    SelectRobotView(selectedRobot: .constant((Robot(serialNumber: "rjghiuesrjghkaes", position: .BL, version: .G21, health: .refurbished, siteID: "fgsugjnvalwk", notes: "gaskfjgvbas"))), availableRobots: [(Robot(serialNumber: "rjghiuesrjghkaes", position: .BL, version: .G21, health: .refurbished, siteID: "fgsugjnvalwk", notes: "gaskfjgvbas"))], isPresented: .constant(false), position: .BL, viewModel: CartViewModel())
}
