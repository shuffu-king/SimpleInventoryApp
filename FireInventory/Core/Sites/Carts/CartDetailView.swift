//
//  CartDetailView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/4/24.
//

import SwiftUI

struct CartDetailView: View {
    let cart: Cart
    @ObservedObject var viewModel: CartViewModel
    @StateObject var robotsViewModel = RobotsViewModel()
    @StateObject var sitesViewModel = SitesViewModel()
    let site: Site
    
    @State private var selectedRobot: String? = nil
    @State private var selectedPosition: PartPosition = .TL
    
    @State private var selectedCart: Cart? = nil
    @State private var isSwapViewPresented = false
    @State private var changeWheelConfirmation = false
    @State private var robotForDetailView: Robot? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundColor.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    robotDetailView(position: .TL, serialNumber: cart.TLserialNumber)
                    robotDetailView(position: .TR, serialNumber: cart.TRserialNumber)
                    robotDetailView(position: .BL, serialNumber: cart.BLserialNumber)
                    robotDetailView(position: .BR, serialNumber: cart.BRserialNumber)
                }
            }
            .background(Color.appBackgroundColor.ignoresSafeArea())
            .toolbarBackground(Color.deepBlue, for: .navigationBar) // Set toolbar background
            .toolbarBackground(.visible, for: .navigationBar)
            .font(.headline)
            .sheet(isPresented: $isSwapViewPresented) {
                SwapRobotView(selectedRobot: $selectedRobot, position: $selectedPosition, isPresented: $isSwapViewPresented, cart: cart, viewModel: viewModel, site: site)
                    .background(Color.appBackgroundColor.ignoresSafeArea())
            }
            .alert(isPresented: $changeWheelConfirmation){
                Alert(
                    title: Text("Replace Mecanum"),
                    message: Text("Are you sure you want to replace this mecanum? This action cannot be undone."),
                    primaryButton: .destructive(Text("Replace")) {
                        Task {
                            if let robot = robotForDetailView {
                                try await robotsViewModel.changeRobotWheel(robot: robot, site: site)
                                try await viewModel.getAllRobots(for: site.id)
                                try await sitesViewModel.getAllItems()
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle(cart.name)
            .padding()
            .onAppear {
                Task {
                    try? await viewModel.getAllRobots(for: site.id) // Refresh robots list on view appear
                }
            }
            .onChange(of: isSwapViewPresented) { _ in
                Task {
                    try? await viewModel.getAllRobots(for: site.id) // Refresh robots list after swap view is dismissed
                }
            }
        }
    }
    
    private func robotSwapButton(robot: String?, position: PartPosition, cart: Cart) -> some View {
        Button {
            selectedPosition = position
            selectedRobot = robot
            selectedCart = cart
            isSwapViewPresented = true
            
            print(selectedPosition)
        } label: {
            Image(systemName: "arrow.left.arrow.right")
                .foregroundColor(.neonGreen)
                .padding()
                .background(Color.deepBlue)
                .cornerRadius(8)
        }
    }
    
    private func robotDetailView(position: PartPosition, serialNumber: String?) -> some View {
        HStack {
            if let serialNumber = serialNumber, let robot = viewModel.getRobot(by: serialNumber) {
                VStack(alignment: .leading) {
                    Text("\(position.rawValue): \(robot.serialNumber)")
                        .font(.headline)
                        .foregroundColor(.offWhite)
                    Text("G\(robot.version.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.offWhite)
                        .opacity(0.7)
                    Text("Mecanum last changed: \(robot.wheelInstallationDate?.formatted(date: .abbreviated, time: .shortened) ?? "None")")
                        .font(.footnote)
                        .foregroundColor(.offWhite)
                        .opacity(0.4)
                }
                
                Spacer()
                
                Button() {
                    robotForDetailView = robot
                    changeWheelConfirmation.toggle()
                } label: {
                    Image(systemName: "circle.hexagonpath.fill")
                        .foregroundColor(.neonGreen)
                        .padding()
                        .background(Color.deepBlue)
                        .clipShape(Circle())
                }
                
                robotSwapButton(robot: serialNumber, position: position, cart: cart)
            } else {
                
                Text("\(position.rawValue): None")
            }
        }
        .padding()
        .background(Color.deepBlue)
        .cornerRadius(12)
    }
}

    #Preview {
        CartDetailView(cart: Cart(name: "test cart"), viewModel: CartViewModel(), robotsViewModel: RobotsViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]))
    }
