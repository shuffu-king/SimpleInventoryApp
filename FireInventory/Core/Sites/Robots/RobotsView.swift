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
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search by Serial Number", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button {
                    if !showScanner {
                        showScanner = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
                .padding()
            }
            
            
            
            Picker("Select Position", selection: $viewModel.selectedPosition){
                Text("All").tag(PartPosition?.none)
                ForEach(PartPosition.allCases, id: \.self){ position in
                    Text(position.rawValue).tag(PartPosition?.some(position))
                    
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            HStack {
                Picker("Select Health", selection: $viewModel.selectedHealth){
                    Text("All").tag(RobotHealth?.none)
                    ForEach(RobotHealth.allCases, id: \.self){ health in
                        Text(health.rawValue).tag(RobotHealth?.some(health))
                        
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Picker("Select Version", selection: $viewModel.selectedVersion){
                    Text("All").tag(RobotVersion?.none)
                    ForEach(RobotVersion.allCases, id: \.self){ version in
                        Text(version.rawValue).tag(RobotVersion?.some(version))
                        
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
            }
            
            
            List{
                ForEach(viewModel.filteredRobots) { robot in
                    
                    NavigationLink(destination: RobotDetailView(robot: robot, siteId: site.id, viewModel: viewModel)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(robot.serialNumber)
                                    .font(.headline)
                                Text(robot.position.rawValue)
                                    .font(.subheadline)
                                    .opacity(0.7)
                                Text("G\(robot.version.rawValue)")
                                    .font(.subheadline)
                                    .opacity(0.7)
                            }
                            Spacer()
                            
                            Text("\(robot.health.rawValue)")
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.visible)
                .navigationTitle("Robots")
                
                
            }
            Button {
                showAddRobotView = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Robot")
                }
            }
        }
        .sheet(isPresented: $showAddRobotView) {
            AddRobotView(site: site, viewModel: viewModel, showAddRobotView: $showAddRobotView)
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
        RobotsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: RobotsViewModel())
    }
}

