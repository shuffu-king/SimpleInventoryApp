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
                    showScanner = true
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
                Button("Add Robot") {
                    Task {
                        let newRobot = Robot(serialNumber: newRobotSN, position: newRobotPosition)
                        await viewModel.addRobot(to: site.id, robot: newRobot)
                        newRobotSN = ""
                        newRobotPosition = .TL
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
    AddRobotView(site: Site(id: "test", name: "test name", location: "test local", items: ["test" : 1], userIDs: ["test_users"], robots: [Robot(serialNumber: "test_SN", position: .TL), Robot(serialNumber: "test_SN2", position: .BL)]), viewModel: RobotsViewModel(), showAddRobotView: .constant(false))
}
