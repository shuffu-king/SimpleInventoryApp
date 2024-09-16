//
//  AddRobotView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/1/24.
//

import SwiftUI

struct AddRobotView: View {
    
    @State private var showScanner = false
    @State private var newRobotSN: String = ""
    @State private var robotNotes: String = ""
    @State private var errorMessage: String? = nil
    @State private var newRobotPosition: PartPosition = .TL
    @State private var newRobotVersion: RobotVersion = .G22
    @State private var newRobotHealth: RobotHealth = .new
    let site: Site
    @ObservedObject var viewModel: RobotsViewModel
    @Binding var showAddRobotView: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Add new Wheel")
                .font(.headline)
                .foregroundColor(.neonGreen)
            ) {
                TextField("New Wheel SN", text: $newRobotSN)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .padding(.vertical, 5)
                    .onChange(of: newRobotSN) {_ in
                        validateSerialNumber()
                    }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Button(action: {
                    if !showScanner {
                        showScanner = true
                    }
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                    }
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.deepBlue)
                    .cornerRadius(10)
                }
                
                Picker("Wheel Position", selection: $newRobotPosition) {
                    ForEach(PartPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                .foregroundStyle(Color.offWhite)
                
                
                Picker("Wheel Version", selection: $newRobotVersion) {
                    ForEach(RobotVersion.allCases, id: \.self) { version in
                        Text(version.rawValue).tag(version)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                .foregroundStyle(Color.offWhite)
                
                
                Picker("Wheel Health", selection: $newRobotHealth) {
                    ForEach(RobotHealth.allCases, id: \.self) { health in
                        Text(health.rawValue).tag(health)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                .foregroundStyle(Color.offWhite)
                
                if newRobotHealth == .damaged {
                    Section(header: Text("Notes")
                        .foregroundColor(.offWhite)) {
                            TextEditor(text: $robotNotes)
                                .frame(height: 100)
                                .background(Color.deepBlue)
                                .foregroundColor(.offWhite)
                        }
                        .listRowBackground(Color.deepBlue)
                }
                
                Button("Add Wheel") {
                    Task {
                        do {
                            let validatedSerialNumber = newRobotSN.uppercased()
                            print(validatedSerialNumber)
                            
                            let robot = Robot(
                                serialNumber: validatedSerialNumber,
                                position: newRobotPosition,
                                version: newRobotVersion,
                                health: newRobotHealth,
                                siteID: "",
                                notes: robotNotes
                            )
                            
                            try await viewModel.addRobot(to: site, robot: robot)
                            
                            showAddRobotView = false

                            errorMessage = nil
                        } catch let error as RobotError {
                            errorMessage = error.localizedDescription
                            return
                        } catch {
                            errorMessage = error.localizedDescription
                            return
                        }
                        newRobotSN = ""
                        newRobotPosition = .TL
                        newRobotVersion = .G22
                        newRobotHealth = .new
                    }
                }
                .disabled(errorMessage != nil || newRobotSN.isEmpty)
                .buttonStyle(PrimaryButtonStyle())
            }
            .listRowBackground(Color.appBackgroundColor)
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView(scannedSN: $newRobotSN)
                .background(Color.appBackgroundColor)
        }
        .background(Color.appBackgroundColor.ignoresSafeArea())
    }
    
    private func validateSerialNumber() {
        let allowedCharacters = CharacterSet.alphanumerics
        if newRobotSN.count != 16 {
            errorMessage = "Serial number must be 16 characters"
        } else if newRobotSN.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            errorMessage = "Serial number can only contain letters and numbers"
        } else {
            errorMessage = nil
        }
    }
}

#Preview {
    AddRobotView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["gagflksjflo"]), viewModel: RobotsViewModel(), showAddRobotView: .constant(false))
}
