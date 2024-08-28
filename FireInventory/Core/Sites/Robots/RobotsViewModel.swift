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
    
    func addRobot(to site: Site, robot: Robot) async throws{
        try await RobotManager.shared.addRobot(to: site, robot: robot)
        try await SitesManager.shared.updateSiteRobots(siteID: site.id, robotID: robot.id, add: true)
        try? await getAllRobots(for: site.id)
        
    }
    
    func deleteRobot(from site: Site, robotID: String) async throws {
        try await RobotManager.shared.deleteRobot(from: site, robotID: robotID)
        try await SitesManager.shared.updateSiteRobots(siteID: site.id, robotID: robotID, add: false)
        try? await getAllRobots(for: site.id)
    }
    
    func updateRobot(from site: Site, robot: Robot) async throws{
        try await RobotManager.shared.updateRobot(robot, site: site)
    }
    
    func siteRobotSwap(from currentSite: Site, to newSite: Site, robotID: String) async throws {
        print("Swapping robot \(robotID) from \(currentSite.id) to \(newSite.id)")
        try await SitesManager.shared.siteRobotSwap(robotID: robotID, from: currentSite, to: newSite)
    }
    
    func changeRobotWheel(robot: Robot, site: Site) async throws {
        try await SitesManager.shared.changeRobotWheel(robot: robot, site: site)
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
    
    func getCartForRobot(robotSerialNumber: String, siteId: String) async throws -> Cart? {
        return try await CartsManager.shared.getCartForRobot(robotSerialNumber: robotSerialNumber, siteId: siteId)
    }
    
    
}
