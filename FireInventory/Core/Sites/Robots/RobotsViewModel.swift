//
//  RobotsViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/29/24.
//

import Foundation

@MainActor
final class RobotsViewModel: ObservableObject {
    @Published private(set) var robots: [Robot] = []
    @Published var selectedPosition: PartPosition? = nil
     
    func getAllRobots(for siteId: String) async {
        do {
            let allRobots = try await SitesManager.shared.getAllRobots(for: siteId)
            self.robots = allRobots
        } catch {
            print("Error fetching robots: \(error)")
        }
    }
    
    func addRobot(to siteId: String, robot: Robot) async {
        do {
            try await SitesManager.shared.addRobot(to: siteId, robot: robot)
            await getAllRobots(for: siteId)
        } catch {
            print("Error adding robot: \(error)")
        }
    }
    
    
    
    var filteredRobots: [Robot] {
        if let position = selectedPosition {
            return robots.filter { $0.position == position }
        } else {
            return robots
        }
    }
    
    
    
    
    
}
