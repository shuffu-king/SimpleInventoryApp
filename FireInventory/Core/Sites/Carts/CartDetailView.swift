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
    let siteId: String
    
    @State private var selectedRobot: String? = nil
    @State private var selectedPosition: PartPosition = .TL
    
    @State private var selectedCart: Cart? = nil
    @State private var isSwapViewPresented = false
//    @State private var isRobotDetailViewPresented = false
//    @State private var robotForDetailView: Robot? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                robotDetailView(position: .TL, serialNumber: cart.TLserialNumber)
                robotDetailView(position: .TR, serialNumber: cart.TRserialNumber)
                robotDetailView(position: .BL, serialNumber: cart.BLserialNumber)
                robotDetailView(position: .BR, serialNumber: cart.BRserialNumber)
            }
            .font(.headline)
            .sheet(isPresented: $isSwapViewPresented) {
                SwapRobotView(selectedRobot: $selectedRobot, position: $selectedPosition, isPresented: $isSwapViewPresented, cart: cart, viewModel: viewModel, siteId: siteId)
            }
//            .sheet(item: $robotForDetailView) { robot in
//                    RobotDetailView(robot: robot, siteId: siteId, viewModel: robotsViewModel)
//            }
            .navigationTitle(cart.name)
            .padding()
            .onAppear {
                Task {
                    try? await viewModel.getAllRobots(for: siteId) // Refresh robots list on view appear
                }
            }
            .onChange(of: isSwapViewPresented) { _ in
                Task {
                    try? await viewModel.getAllRobots(for: siteId) // Refresh robots list after swap view is dismissed
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
            Image(systemName: "arrow.triangle.swap")
                .foregroundColor(.blue)
        }
    }
    
    private func robotDetailView(position: PartPosition, serialNumber: String?) -> some View {
        HStack {
            if let serialNumber = serialNumber, let robot = viewModel.getRobot(by: serialNumber) {
                VStack(alignment: .leading) {
                    Text("\(position.rawValue): \(robot.serialNumber)")
                    Text("(G\(robot.version.rawValue))")
                        .opacity(0.5)
                }
                
                Spacer()
                
                Button() {
//                    robotForDetailView = robot
//                    isRobotDetailViewPresented.toggle()
                } label: {
                    Image(systemName: "transmission")
                }
                
                robotSwapButton(robot: serialNumber, position: position, cart: cart)
            } else {
                
                Text("\(position.rawValue): None")
            }
        }
    }
}

    #Preview {
        CartDetailView(cart: Cart(name: "test cart"), viewModel: CartViewModel(), robotsViewModel: RobotsViewModel(), siteId: "Asdgadgasd")
    }
