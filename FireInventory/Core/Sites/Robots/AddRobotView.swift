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
    @State private var errorMessage: String? = nil
    @State private var newRobotPosition: PartPosition = .TL
    @State private var newRobotVersion: RobotVersion = .G22
    @State private var newRobotHealth: RobotHealth = .new
    let site: Site
    @ObservedObject var viewModel: RobotsViewModel
    @Binding var showAddRobotView: Bool
    
    var body: some View {
        Form{
            Section(header: Text("Add new Robot")) {
                TextField("New Robot SN", text: $newRobotSN)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.characters)
                    .padding(.vertical, 5)
                    .onChange(of: newRobotSN) {_ in
                        validateSerialNumber()
                    }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                              
                Button {
                    if !showScanner {
                        showScanner = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                    }
                }
                
                
                Picker("Robot Position", selection: $newRobotPosition) {
                    ForEach(PartPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                
                Picker("Robot Version", selection: $newRobotVersion) {
                    ForEach(RobotVersion.allCases, id: \.self) { version in
                        Text(version.rawValue).tag(version)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                
                Picker("Robot Health", selection: $newRobotHealth) {
                    ForEach(RobotHealth.allCases, id: \.self) { health in
                        Text(health.rawValue).tag(health)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                
                Button("Add Robot") {
                    Task {
                        let newRobot = Robot(serialNumber: newRobotSN, position: newRobotPosition, version: newRobotVersion, health: newRobotHealth, siteID: site.id)
                        try await viewModel.addRobot(to: site.id, robot: newRobot)
                        newRobotSN = ""
                        newRobotPosition = .TL
                        newRobotVersion = .G22
                        newRobotHealth = .new
                    }
                    showAddRobotView = false
                }
                .disabled(errorMessage != nil || newRobotSN.isEmpty)
                .buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle("Add Robot")
            .sheet(isPresented: $showScanner) {
                QRScannerView(scannedSN: $newRobotSN)
            }
        }
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
    AddRobotView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], damagedItems: ["test" : 2], userIDs: ["test_users"], robotIDs: ["gagflksjflo"]), viewModel: RobotsViewModel(), showAddRobotView: .constant(false))
}
