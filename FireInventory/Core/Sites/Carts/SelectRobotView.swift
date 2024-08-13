//
//  SelectRobotView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/10/24.
//

import SwiftUI

struct SelectRobotView: View {
    @Binding var selectedRobot: Robot?
    let availableRobots: [Robot]
    @Binding var isPresented: Bool
    let position: PartPosition
    let viewModel: CartViewModel
    
    var newRobots: [Robot] {
        availableRobots.filter { $0.health == .new }
    }
    
    var refurbishedRobots: [Robot] {
        availableRobots.filter { $0.health == .refurbished }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Text("\(position.rawValue) selection")
                
                if !newRobots.isEmpty {
                    Section("New Robots") {
                        ForEach(newRobots) { robot in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(robot.serialNumber)
                                    Text("G\(robot.version.rawValue)")
                                        .opacity(0.4)
                                }
                                Spacer()
                                Button("Select") {
                                    selectedRobot = robot
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
                
                if !refurbishedRobots.isEmpty {
                    Section("Refurbished Robots") {
                        ForEach(refurbishedRobots) { robot in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(robot.serialNumber)
                                    Text("G\(robot.version.rawValue)")
                                        .opacity(0.4)
                                }
                                Spacer()
                                Button("Select") {
                                    selectedRobot = robot
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Robot")
        }
        .padding()
    }
}

//#Preview {
//    SelectRobotView()
//}
