//
//  RobotsViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/29/24.
//

import Foundation

@MainActor
final class RobotsViewModel: ObservableObject {
    @Published var robots: [Robot] = []
    @Published var selectedPosition: PartPosition? = nil
    @Published var selectedHealth: RobotHealth? = nil
    @Published var selectedVersion: RobotVersion? = nil
    @Published var searchQuery = ""
    
    func getAllRobots(for siteID: String) async throws {
        self.robots = try await RobotManager.shared.getAllRobots(for: siteID)
    }
    
    func addRobot(to siteId: String, robot: Robot) async throws{
        try await RobotManager.shared.addRobot(to: siteId, robot: robot)
        try await SitesManager.shared.updateSiteRobots(siteID: siteId, robotID: robot.id, add: true)
        try? await getAllRobots(for: siteId)
        
    }
    
    func deleteRobot(from siteID: String, robotID: String) async throws {
        try await RobotManager.shared.deleteRobot(from: siteID, robotID: robotID)
        try await SitesManager.shared.updateSiteRobots(siteID: siteID, robotID: robotID, add: false)
        try? await getAllRobots(for: siteID)
    }
    
    func updateRobot(from siteId: String, robot: Robot) async throws{
        try await RobotManager.shared.updateRobot(robot, siteId: siteId)
        
    }
    
    func siteRobotSwap(from currentSiteId: String, to newSiteId: String, robotID: String) async throws {
        print("Swapping robot \(robotID) from \(currentSiteId) to \(newSiteId)")
        try await SitesManager.shared.siteRobotSwap(robotID: robotID, from: currentSiteId, to: newSiteId)
        
//        // Reload data for both sites
//        try await getAllRobots(for: currentSiteId)
//        try await getAllRobots(for: newSiteId)
//        
    }
    
    var filteredRobots: [Robot] {
        robots.filter { robot in
            let matchesPosition = selectedPosition == nil || robot.position == selectedPosition
            let matchesHealth = selectedHealth == nil || robot.health == selectedHealth
            let matchesVersion = selectedVersion == nil || robot.version == selectedVersion
            let matchesSearchText = searchQuery.isEmpty || robot.serialNumber.lowercased().contains(searchQuery.lowercased())
            
            return matchesPosition && matchesHealth && matchesVersion && matchesSearchText
        }
    }
    
    
}
