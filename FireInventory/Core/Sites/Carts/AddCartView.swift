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
    let site: Site
    
    @State private var isSelectRobotPresented = false
    @State private var selectedPosition: PartPosition = .TL
    @State private var showAlert = false
    @State private var showNameAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundColor.ignoresSafeArea()
                VStack {
                    Form {
                        Section("Cart Details") {
                            
                            ZStack(alignment: .leading) {
                                if cartName.isEmpty {
                                    Text("Enter Cart Name")
                                        .foregroundColor(.offWhite)
                                        .padding(.leading, -0)
                                }
                                
                                TextField("", text: $cartName)
                                    .foregroundStyle(Color.offWhite)
                                    .font(.headline)
                            }
                            
                            
                            
                            
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
                        .listRowBackground(Color.deepBlue)
                        
                        Button("Create New Cart") {
                            print("Create New Cart button pressed")
                            Task {
                                    if !cartName.isEmpty {
                                        let newCart = Cart(
                                            id: UUID().uuidString,
                                            name: cartName,
                                            TLserialNumber: selectedTopLeft?.serialNumber,
                                            TRserialNumber: selectedTopRight?.serialNumber,
                                            BLserialNumber: selectedBackLeft?.serialNumber,
                                            BRserialNumber: selectedBackRight?.serialNumber
                                        )
                                        
                                        do {
                                            try await viewModel.addCart(for: site, cart: newCart)
                                            print("Cart added") // Check if this appears in console
                                            presentationMode.wrappedValue.dismiss()
                                        } catch {
                                            print("Failed to add cart: \(error.localizedDescription)")
                                            showNameAlert = true
                                        }
                                    } else {
                                        showAlert.toggle()
                                    }
                                }
                        }
                        .foregroundStyle(Color.offWhite)
                        .listRowBackground(Color.deepBlue)
                    }
                }

            }
            .navigationTitle("Create New Cart")
            .task {
                try? await viewModel.getAllRobots(for: site.id)
                try? await viewModel.getAllCarts(for: site.id)
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
            .alert("Cart name already taken", isPresented: $showNameAlert) {
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
    AddCartView(viewModel: CartViewModel(), site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["hbkjbkjbk"]))
}
