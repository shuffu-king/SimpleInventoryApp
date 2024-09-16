//
//  AddSetRobotsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/30/24.
//

import SwiftUI

struct AddSetRobotsView: View {
    
    let site: Site
    @ObservedObject var viewModel: RobotsViewModel
    @State private var tLSN: String = ""
    @State private var tRSN: String = ""
    @State private var bLSN: String = ""
    @State private var bRSN: String = ""
    @State private var showScanner = false
    @State private var newRobotsVersion: RobotVersion = .G22
    @State private var newRobotsHealth: RobotHealth = .new
    @Binding var showAddSetRobotView: Bool
    @State private var position: PartPosition = .TL
    @State private var errorMessageTL: String? = ""
    @State private var errorMessageTR: String? = ""
    @State private var errorMessageBL: String? = ""
    @State private var errorMessageBR: String? = ""
    @State private var overallErrorMessage: String? = nil  // New state for overall error message
    
    var body: some View {
        Form {
            Section(header: Text("Add set of wheels")
                .font(.headline)
                .foregroundColor(.neonGreen)
            ) {
                
                HStack {
                    VStack {
                        TextField("New TL Wheel SN", text: $tLSN)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.characters)
                            .padding(.vertical, 5)
                            .onChange(of: tLSN) {_ in
                                validateSerialNumber(serialNumber: tLSN, errorMessage: $errorMessageTL)
                            }
                        
                        if let errorMessageTL = errorMessageTL {
                            Text(errorMessageTL)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    Button {
                        showScanner.toggle()
                        position = .TL
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.headline)
                            .padding()
                            .background(Color.neonGreen)
                            .foregroundStyle(Color.deepBlue)
                            .cornerRadius(12)
                    }
                    
                }
                HStack {
                    VStack {
                        TextField("New TR Wheel SN", text: $tRSN)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.characters)
                            .padding(.vertical, 5)
                            .onChange(of: tRSN) {_ in
                                validateSerialNumber(serialNumber: tRSN, errorMessage: $errorMessageTR)
                            }
                        
                        if let errorMessageTR = errorMessageTR {
                            Text(errorMessageTR)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    Button {
                        showScanner.toggle()
                        position = .TR
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.headline)
                            .padding()
                            .background(Color.neonGreen)
                            .foregroundStyle(Color.deepBlue)
                            .cornerRadius(12)
                    }
                    
                }
                HStack {
                    VStack {
                        TextField("New BL Wheel SN", text: $bLSN)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.characters)
                            .padding(.vertical, 5)
                            .onChange(of: bLSN) {_ in
                                validateSerialNumber(serialNumber: bLSN, errorMessage: $errorMessageBL)
                            }
                        
                        if let errorMessageBL = errorMessageBL {
                            Text(errorMessageBL)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    Button {
                        showScanner.toggle()
                        position = .BL
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.headline)
                            .padding()
                            .background(Color.neonGreen)
                            .foregroundStyle(Color.deepBlue)
                            .cornerRadius(12)
                    }
                    
                }
                HStack {
                    VStack {
                        TextField("New BR Wheel SN", text: $bRSN)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.characters)
                            .padding(.vertical, 5)
                            .onChange(of: bRSN) {_ in
                                validateSerialNumber(serialNumber: bRSN, errorMessage: $errorMessageBR)
                            }
                        
                        if let errorMessageBR = errorMessageBR {
                            Text(errorMessageBR)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    Button {
                        showScanner.toggle()
                        position = .BR
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.headline)
                            .padding()
                            .background(Color.neonGreen)
                            .foregroundStyle(Color.deepBlue)
                            .cornerRadius(12)
                    }
                }
                
                Picker("Set Version", selection: $newRobotsVersion) {
                    ForEach(RobotVersion.allCases, id: \.self) { version in
                        Text(version.rawValue).tag(version)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                .foregroundStyle(Color.offWhite)
                
                Picker("Set Health", selection: $newRobotsHealth) {
                    ForEach(RobotHealth.allCases, id: \.self) { health  in
                        if health != .damaged {
                            Text(health.rawValue).tag(health)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                .foregroundStyle(Color.offWhite)
                
                Button("Add Set") {
                    Task {
                        let robotSN = [tLSN.uppercased(), tRSN.uppercased(), bLSN.uppercased(), bRSN.uppercased()]
                        
                        // Check for existing robots
                        do {
                            let existingSerialNumbers = try await viewModel.checkExistingRobots(site: site, serialNumbers: robotSN)
                            
                            if !existingSerialNumbers.isEmpty {
                                overallErrorMessage = "The following serial numbers already exist: \(existingSerialNumbers.joined(separator: ", "))"
                                return
                            }
                            
                            let positions: [PartPosition] = [.TL, .TR, .BL, .BR]
                            
                            for (index, serialNumber) in robotSN.enumerated() {
                                if !serialNumber.isEmpty {
                                    let robot = Robot(
                                        serialNumber: serialNumber,
                                        position: positions[index],
                                        version: newRobotsVersion,
                                        health: newRobotsHealth,
                                        siteID: site.id
                                    )
                                    try await viewModel.addRobot(to: site, robot: robot)
                                }
                            }
                            
                            // Close the view on success
                            showAddSetRobotView = false
                        } catch {
                            overallErrorMessage = error.localizedDescription
                        }
                    }
                }
                .disabled(errorMessageTL != nil || errorMessageTR != nil || errorMessageBL != nil || errorMessageBR != nil || tLSN.isEmpty || tRSN.isEmpty || bLSN.isEmpty || bRSN.isEmpty)
                .buttonStyle(PrimaryButtonStyle())
                
                // Show overall error message if any serial numbers are duplicated
                if let overallErrorMessage = overallErrorMessage {
                    Text(overallErrorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top)
                }
                
            }
            .listRowBackground(Color.appBackgroundColor)
        }
        .sheet(isPresented: $showScanner) {
            switch position {
            case .TL:
                QRScannerView(scannedSN: $tLSN)
            case .TR:
                QRScannerView(scannedSN: $tRSN)
            case .BL:
                QRScannerView(scannedSN: $bLSN)
            case .BR:
                QRScannerView(scannedSN: $bRSN)
            }
        }
    }
    
    private func validateSerialNumber(serialNumber: String, errorMessage: Binding<String?>) {
        let allowedCharacters = CharacterSet.alphanumerics
        if serialNumber.count != 16 {
            errorMessage.wrappedValue = "Serial number must be 16 characters"
        } else if serialNumber.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            errorMessage.wrappedValue = "Serial number can only contain letters and numbers"
        } else {
            errorMessage.wrappedValue = nil
        }
    }
}

#Preview {
    AddSetRobotsView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], inUseItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["test_ids"]), viewModel: RobotsViewModel(), showAddSetRobotView: .constant(false))
}
