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
    let siteId: String
    
    @State private var selectedRobot: String? = nil
    @State private var selectedPosition: PartPosition = .TL
    
    @State private var selectedCart: Cart? = nil
    @State private var isSwapViewPresented = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                
                //                HStack {
                //                    Text("TL: \(cart.TLserialNumber ?? "None")")
                //                    Spacer()
                //                    robotSwapButton(robot: cart.TLserialNumber, position: .TL, cart: cart)
                //                }
                
                //                HStack {
                //                    Text("TR: \(cart.TRserialNumber ?? "None")")
                //                    Spacer()
                //                    robotSwapButton(robot: cart.TRserialNumber, position: .TR, cart: cart)
                //                }
                
                //                HStack {
                //                    Text("BL: \(cart.BLserialNumber ?? "None")")
                //                    Spacer()
                //                    robotSwapButton(robot: cart.BLserialNumber, position: .BL, cart: cart)
                //                }
                
                //                HStack {
                //                    Text("BR: \(cart.BRserialNumber ?? "None")")
                //                    Spacer()
                //                    robotSwapButton(robot: cart.BRserialNumber, position: .BR, cart: cart)
                //                }
                
                robotDetailView(position: .TL, serialNumber: cart.TLserialNumber)
                robotDetailView(position: .TR, serialNumber: cart.TRserialNumber)
                robotDetailView(position: .BL, serialNumber: cart.BLserialNumber)
                robotDetailView(position: .BR, serialNumber: cart.BRserialNumber)
            }
            .font(.headline)
            .sheet(isPresented: $isSwapViewPresented) {
                
                SwapRobotView(selectedRobot: $selectedRobot, position: $selectedPosition, isPresented: $isSwapViewPresented, cart: cart, viewModel: viewModel, siteId: siteId)
            }
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

            } else {
                Text("\(position.rawValue): None")
            }
            Spacer()
            robotSwapButton(robot: serialNumber, position: position, cart: cart)
        }
    }
}

#Preview {
    CartDetailView(cart: Cart(name: "test cart"), viewModel: CartViewModel(), siteId: "Asdgadgasd")
}
