//
//  RobotsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/24/24.
//

import SwiftUI

struct RobotsView: View {
    let site: Site
    @ObservedObject var viewModel = RobotsViewModel()
    @State private var showAddRobotView = false
    @State private var showScanner = false
    @State private var showAddSetView = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                TextField("Search by Serial Number", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
        
                Button {
                    showScanner.toggle()
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .padding()
                        .background(Color.neonGreen)
                        .foregroundStyle(Color.deepBlue)
                        .cornerRadius(12)
                }
                .padding(.trailing)
            }
            
            // Filter Pickers
            VStack(spacing: 10) {
                Picker("Select Position", selection: $viewModel.selectedPosition) {
                    Text("All").tag(PartPosition?.none)
                    ForEach(PartPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(PartPosition?.some(position))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                HStack(spacing: 5) {
                    Picker("Select Health", selection: $viewModel.selectedHealth) {
                        Text("Health").tag(RobotHealth?.none)
                        ForEach(RobotHealth.allCases, id: \.self) { health in
                            Text(health.rawValue).tag(RobotHealth?.some(health))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Select Version", selection: $viewModel.selectedVersion) {
                        Text("Version").tag(RobotVersion?.none)
                        ForEach(RobotVersion.allCases, id: \.self) { version in
                            Text(version.rawValue).tag(RobotVersion?.some(version))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Select RSOs", selection: $viewModel.selectedRSOsCompleted) {
                        // If RSOs, should show all robots
                        Text("RSOs").tag(Bool?.none)
                        Text("Yes").tag(Bool?.some(true))
                        Text("No").tag(Bool?.some(false))
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                    
                    Text("Total: \(viewModel.filteredRobots.count)")
                        .font(.headline)
                        .foregroundStyle(Color.offWhite)
                }
                .padding(.horizontal)
            }
            
            // List of Robots
            ScrollView {
                ForEach(viewModel.filteredRobots) { robot in
                    NavigationLink(destination: RobotDetailView(robot: robot, site: site, viewModel: viewModel)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(robot.serialNumber)
                                    .font(.headline)
                                    .foregroundStyle(Color.offWhite)
                                
                                Text(robot.position.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.offWhite)
                                    .opacity(0.7)
                                
                                Text("G\(robot.version.rawValue)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.offWhite)
                                    .opacity(0.7)
                            }
                            
                            Spacer()
                            
                            Text(robot.health.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(Color.offWhite)
                        }
                        .padding()
                        .background(Color.deepBlue)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            
            HStack {
                // Add Robot Button
                Button {
                    showAddRobotView = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Wheel")
                    }
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.vertical, 10)
                
                Button {
                    showAddSetView.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Set (4)")
                    }
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.neonGreen)
                    .foregroundColor(Color.deepBlue)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color(Color.appBackgroundColor))
        .sheet(isPresented: $showAddRobotView) {
            ZStack {
                Color.appBackgroundColor.ignoresSafeArea()
                AddRobotView(site: site, viewModel: viewModel, showAddRobotView: $showAddRobotView)
            }
        }
        .sheet(isPresented: $showAddSetView){
            AddSetRobotsView(site: site, viewModel: viewModel, showAddSetRobotView: $showAddSetView)
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView(scannedSN: $viewModel.searchQuery)
        }
        .task {
            try? await viewModel.getAllRobots(for: site.id)
        }
        
    }
}

#Preview {
    NavigationStack {
        RobotsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: RobotsViewModel())
    }
}

