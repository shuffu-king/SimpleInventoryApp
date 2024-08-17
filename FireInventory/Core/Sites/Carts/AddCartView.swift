//
//  AddCartView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/4/24.
//

import SwiftUI

struct AddCartView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var cartName = ""
    @State private var selectedTopLeft: Robot? = nil
    @State private var selectedTopRight: Robot? = nil
    @State private var selectedBackLeft: Robot? = nil
    @State private var selectedBackRight: Robot? = nil
    @ObservedObject var viewModel: CartViewModel
    let siteId: String
    
    @State private var isSelectRobotPresented = false
    @State private var selectedPosition: PartPosition = .TL
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Cart Details") {
                    TextField("Cart Name", text: $cartName)
                    
                    Button("Select TL") {
                        selectedPosition = .TL
                        isSelectRobotPresented = true
                    }
                    if let selectedTopLeft = selectedTopLeft {
                        VStack(alignment: .leading) {
                            Text("\(selectedTopLeft.serialNumber)")
                            Text("G\(selectedTopLeft.version.rawValue)")
                                .opacity(0.4)
                        }
                    }
                    
                    Button("Select TR") {
                        selectedPosition = .TR
                        isSelectRobotPresented = true
                    }
                    if let selectedTopRight = selectedTopRight {
                        VStack(alignment: .leading) {
                            Text("\(selectedTopRight.serialNumber)")
                            Text("G\(selectedTopRight.version.rawValue)")
                                .opacity(0.4)
                        }
                    }
                    
                    Button("Select BL") {
                        selectedPosition = .BL
                        isSelectRobotPresented = true
                    }
                    if let selectedBackLeft = selectedBackLeft {
                        VStack (alignment: .leading){
                            Text("\(selectedBackLeft.serialNumber)")
                            Text("G\(selectedBackLeft.version.rawValue)")
                                .opacity(0.4)
                        }
                    }
                    
                    Button("Select BR") {
                        selectedPosition = .BR
                        isSelectRobotPresented = true
                    }
                    if let selectedBackRight = selectedBackRight {
                        VStack(alignment: .leading) {
                            Text("\(selectedBackRight.serialNumber)")
                            Text("G\(selectedBackRight.version.rawValue)")
                                .opacity(0.4)
                        }
                    }
                    
                }
                
                Button("Add Cart") {
                    
                    if !cartName.isEmpty {
                        let newCart = Cart(
                            name: cartName,
                            TLserialNumber: selectedTopLeft?.serialNumber,
                            TRserialNumber: selectedTopRight?.serialNumber,
                            BLserialNumber: selectedBackLeft?.serialNumber,
                            BRserialNumber: selectedBackRight?.serialNumber
                        )
                        
                        Task{
                            try await viewModel.addCart(for: siteId, cart: newCart)
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        showAlert.toggle()
                    }
                }
            }
            .navigationTitle("Add Cart")
            .task {
                try? await viewModel.getAllRobots(for: siteId)
                try? await viewModel.getAllCarts(for: siteId)
            }
            .toolbar {
                if !((serialForSelectedPosition()?.isEmpty) == nil) {
                    Button("Clear") {
                        clearSelectedRobots()
                    }
                }
            }
            .sheet(isPresented: $isSelectRobotPresented) {
                SelectRobotView(
                    selectedRobot: bindingForSelectedPosition(),
                    availableRobots: viewModel.getAvailableRobots(for: selectedPosition, currentRobotSerial: serialForSelectedPosition()),
                    isPresented: $isSelectRobotPresented,
                    position: selectedPosition,
                    viewModel: viewModel
                )
            }
            .alert("One or more fields missing", isPresented: $showAlert) {
                Button("OK", role: .cancel){ }
            }
        }
    }
    
    private func bindingForSelectedPosition() -> Binding<Robot?> {
        switch selectedPosition {
        case .TL:
            return $selectedTopLeft
        case .TR:
            return $selectedTopRight
        case .BL:
            return $selectedBackLeft
        case .BR:
            return $selectedBackRight
        }
    }
    
    private func serialForSelectedPosition() -> String? {
        switch selectedPosition {
        case .TL:
            return selectedTopLeft?.serialNumber
        case .TR:
            return selectedTopRight?.serialNumber
        case .BL:
            return selectedBackLeft?.serialNumber
        case .BR:
            return selectedBackRight?.serialNumber
        }
    }
    
    private func clearSelectedRobots() {
        selectedTopLeft = nil
        selectedTopRight = nil
        selectedBackLeft = nil
        selectedBackRight = nil
    }
}

#Preview {
    AddCartView(viewModel: CartViewModel(), siteId: "asdrujgfhasdjkl")
}
