//
//  RobotManager.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/2/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class RobotManager {
    
    static let shared = RobotManager()
    private init() { }
    
    private let db = Firestore.firestore()
    private let robotsCollection = Firestore.firestore().collection("robots")
    private let transactionsCollection = Firestore.firestore().collection("transactions")
    private let currentUser = AuthenticationManager.shared.getCurrentUserEmail() ?? "unknown"
    
    func getAllRobots(for siteID: String) async throws -> [Robot] {
        let snapshot = try await robotsCollection.whereField("siteID", isEqualTo: siteID).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Robot.self) }
    }
    
    func addRobot(to site: Site, robot: Robot) async throws {
        
        let documentRef = robotsCollection.document(robot.serialNumber)
        try documentRef.setData(from: robot)
        
        let transactionRecord = Transaction(entityType: "robot", entityId: robot.serialNumber, siteId: site.name, action: "add", userId: currentUser)
        try transactionsCollection.addDocument(from: transactionRecord)
    }
    
    func deleteRobot(from site: Site, robotID: String) async throws {
        
        let documentRef = robotsCollection.document(robotID)
        try await documentRef.delete()
        
        let transactionRecord = Transaction(entityType: "robot", entityId: robotID, siteId: site.name, action: "delete", userId: currentUser)
        try  transactionsCollection.addDocument(from: transactionRecord)
    }
    
    func updateRobot(_ robot: Robot, site: Site) async throws {
        let documentRef = robotsCollection.document(robot.serialNumber)
        try documentRef.setData(from: robot)
        
        let transactionRecord = Transaction(entityType: "robot", entityId: robot.serialNumber, siteId: site.name, action: "update", userId: currentUser, notes:  "health changed to \(robot.health.rawValue)")
        try transactionsCollection.addDocument(from: transactionRecord)
    }
}

