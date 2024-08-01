//
//  RobotsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/24/24.
//

import SwiftUI

struct RobotsView: View {
    let site: Site
    //    @ObservedObject var viewModel: SitesViewModel
    @ObservedObject var viewModel = RobotsViewModel()
    @State private var showAddRobotView = false
    
    
    var body: some View {
        VStack {
            Picker("Select Position", selection: $viewModel.selectedPosition){
                Text("All").tag(PartPosition?.none)
                ForEach(PartPosition.allCases, id: \.self){ position in
                    Text(position.rawValue).tag(PartPosition?.some(position))
                    
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            List{
                ForEach(viewModel.filteredRobots) { robot in
                    VStack(alignment: .leading) {
                        Text(robot.serialNumber)
                            .font(.headline)
                        Text(robot.position.rawValue)
                            .font(.subheadline)
                            .opacity(0.7)
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
        .task {
            await viewModel.getAllRobots(for: site.id)
        }
        
    }
}

#Preview {
    NavigationStack {
        RobotsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], userIDs: ["test_users"], robots: [Robot(serialNumber: "test_SN", position: .TL), Robot(serialNumber: "test_SN2", position: .BL)]), viewModel: RobotsViewModel())
    }
}
