//
//  CartViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class CartViewModel: ObservableObject {
    
    @Published private(set) var carts: [Cart] = []
    @Published private(set) var robots: [Robot] = []
    
    
    func getAllCarts(for siteId: String) async throws {
        do {
            self.carts = try await CartsManager.shared.getCarts(for: siteId)
        } catch {
            print("Error fetching carts: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getAllRobots(for siteID: String) async throws {
        self.robots = try await RobotManager.shared.getAllRobots(for: siteID)
    }
    
    func addCart(for site: Site, cart: Cart) async throws {
        do {
            try await CartsManager.shared.addCart(cart, to: site)
            try await getAllCarts(for: site.id)
        } catch {
            print("Error adding cart: \(error.localizedDescription)")
        }
    }
    
    func deleteCart(for site: Site, cart: Cart) async throws {
        do {
            try await CartsManager.shared.deleteCart(cart, from: site)
            try await getAllCarts(for: site.id)
        } catch {
            print("Error deleting cart: \(error.localizedDescription)")
        }    }
    
    func updateCart(for site: Site, cart: Cart) async throws {
        do {
            try await CartsManager.shared.updateCart(cart, in: site)
            try await getAllCarts(for: site.id)
        } catch {
            print("Error updating cart: \(error.localizedDescription)")
        }
    }
    
    func swapRobot(in cart: Cart, for position: PartPosition, with newRobotSN: String, from site: Site, notes: String?) async throws{
        
        do {
            try await CartsManager.shared.swapRobot(in: cart, at: position, with: newRobotSN, for: site, notes: notes)
            try await getAllCarts(for: site.id)
        } catch {
            print("Error updating cart: \(error)")
        }
    }
    
    func updateRobot(from site: Site, robot: Robot) async throws{
        try await RobotManager.shared.updateRobot(robot, site: site)
    }
    
    func getAvailableRobots(for position: PartPosition, currentRobotSerial: String?) -> [Robot] {
        
        //        guard let currentRobotSerial = currentRobotSerial,
        //              let currentRobot = getRobot(by: currentRobotSerial) else {
        //                return []
        //        }
//        let currentRobotVersion = robots.first { $0.serialNumber == currentRobotSerial }?.version
        
        let assignedRobotSerialNumbers = Set(carts.flatMap { [$0.TLserialNumber, $0.TRserialNumber, $0.BLserialNumber, $0.BRserialNumber] })
        return robots.filter { robot in
//            (currentRobotVersion == nil || robot.version == currentRobotVersion) &&
            robot.position == position &&
            (robot.health == .new || robot.health == .refurbished) &&
            !assignedRobotSerialNumbers.contains(robot.serialNumber)
        }
    }
    
    func getRobot(by serialNumber: String) -> Robot? {
        return robots.first { $0.serialNumber == serialNumber }
    }
    
    func updateCartName(cart: Cart, newName: String, site: Site) async throws {
        do {
            try await CartsManager.shared.updateCartName(cart: cart, newName: newName, site: site)
            try await getAllCarts(for: site.id)
        } catch {
            print("Error updating cart: \(error.localizedDescription)")
        }
    }
}
