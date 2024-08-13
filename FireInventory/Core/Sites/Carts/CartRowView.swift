////
////  CartRowView.swift
////  FireInventory
////
////  Created by Ayo Shafau on 8/4/24.
////
//
//import SwiftUI
//
//struct CartRowView: View {
//    
//    let cart: Cart
//    @ObservedObject var viewModel: CartViewModel
//    let siteId: String
//    
//    @State private var isExpanded = false
//    @State private var isSwapViewPresented = false
//    @State private var selectedRobot: String? = nil
//    @State private var selectedPosition: PartPosition = .TL
//    @State private var selectedCart: Cart? = nil
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack{
//                Text(cart.name)
//                
//                Spacer()
//                
//                Button {
//                    isExpanded.toggle()
//                } label: {
//                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                        .foregroundColor(.blue)
//                }
//            }
//            
//            if isExpanded {
//                VStack(alignment: .leading, spacing: 10) {
//                    HStack {
//                        Text("TL: \(cart.TLserialNumber ?? "None")")
//                        Spacer()
//                        robotSwapButton(robot: cart.TLserialNumber, position: .TL, cart: cart)
//                    }
//                    
//                    HStack {
//                        Text("TR: \(cart.TRserialNumber ?? "None")")
//                        Spacer()
//                        robotSwapButton(robot: cart.TRserialNumber, position: .TR, cart: cart)
//                    }
//                    
//                    HStack {
//                        Text("BL: \(cart.BLserialNumber ?? "None")")
//                        Spacer()
//                        robotSwapButton(robot: cart.BLserialNumber, position: .BL, cart: cart)
//                    }
//                    
//                    HStack {
//                        Text("BR: \(cart.BRserialNumber ?? "None")")
//                        Spacer()
//                        robotSwapButton(robot: cart.BRserialNumber, position: .BR, cart: cart)
//                    }
//                }
//                .padding(.top, 5)
//            }
//        }
//        .sheet(isPresented: $isSwapViewPresented) {
//            SwapRobotView(selectedRobot: $selectedRobot, availableRobots: viewModel.getAvailableRobots(for: selectedPosition), position: selectedPosition, isPresented: $isSwapViewPresented)
//                .onDisappear {
//                    if let selectedRobot = selectedRobot {
//                        Task {
//                            try await viewModel.swapRobot(in: cart, for: selectedPosition, with: selectedRobot, from: siteId)
//                        }
//                    }
//                }
//        }
//    }
//    
//    private func robotSwapButton(robot: String?, position: PartPosition, cart: Cart) -> some View {
//        Button {
//            selectedRobot = robot
//            selectedPosition = position
//            selectedCart = cart
//            isSwapViewPresented = true
//        } label: {
//            Image(systemName: "arrow.triangle.swap")
//                .foregroundColor(.blue)
//        }
//    }
//}
//
//#Preview {
//    CartRowView(cart: Cart(name: "test cart"), viewModel: CartViewModel(), siteId: "Asdgadgasd")
//}
