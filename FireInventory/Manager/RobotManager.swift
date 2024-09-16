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
    
    //    func addRobot(to site: Site, robot: Robot) async throws {
    //
    //        // Check if the robot already exists in the collection
    //        let existingRobotSnapshot = try await robotsCollection.document(robot.serialNumber).getDocument()
    //
    //        if let existingRobot = try? existingRobotSnapshot.data(as: Robot.self) {
    //            // If the robot exists and is already assigned to a site, return an error
    //            if !existingRobot.siteID.isEmpty {
    //                throw NSError(domain: "RobotManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "This robot is already assigned to a site."])
    //            }
    //        } else {
    //
    //            let documentRef = robotsCollection.document(robot.serialNumber)
    //            try documentRef.setData(from: robot)
    //
    //
    //            //Log transaction
    //            let transactionRecord = Transaction(entityType: "robot", entityId: robot.serialNumber, siteId: site.name, action: "add", userId: currentUser)
    //            try transactionsCollection.addDocument(from: transactionRecord)
    //        }
    //    }
    
    func addRobot(to site: Site, robot: Robot) async throws {
        let documentRef = robotsCollection.document(robot.serialNumber)
        let existingRobotSnapshot = try await documentRef.getDocument()
        
        if existingRobotSnapshot.exists {
            // Robot already exists in the collection
            if var existingRobot = try? existingRobotSnapshot.data(as: Robot.self) {
                if existingRobot.siteID.isEmpty {
                    // Robot exists but is unassigned, proceed to assign to the site
                    existingRobot.siteID = site.id
                    try documentRef.setData(from: existingRobot)
                    
                    // Update site's robot list
                    try await SitesManager.shared.updateSiteRobots(siteID: site.id, robotID: existingRobot.serialNumber, add: true)
                    
                    // Log transaction
                    let transactionRecord = Transaction(
                        entityType: "robot",
                        entityId: existingRobot.serialNumber,
                        siteId: site.name,
                        action: "add",
                        userId: currentUser,
                        notes: "Assigned existing robot to site"
                    )
                    try transactionsCollection.addDocument(from: transactionRecord)
                } else {
                    // Robot is already assigned to a site
                    throw RobotError.robotAlreadyAssigned(siteID: existingRobot.siteID)
                }
            } else {
                throw RobotError.invalidRobotData
            }
        } else {
            // Robot does not exist, create new robot and assign to site
            var newRobot = robot
            newRobot.siteID = site.id
            try documentRef.setData(from: newRobot)
            
            // Update site's robot list
            try await SitesManager.shared.updateSiteRobots(siteID: site.id, robotID: newRobot.serialNumber, add: true)
            
            // Log transaction
            let transactionRecord = Transaction(
                entityType: "robot",
                entityId: newRobot.serialNumber,
                siteId: site.name,
                action: "add",
                userId: currentUser,
                notes: "Added new robot to site"
            )
            try transactionsCollection.addDocument(from: transactionRecord)
        }
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
    
    // Function to check if a robot exists in the collection
    func robotExistsInCollection(serialNumber: String) async throws -> Bool {
        // Reference to the "robots" collection in Firestore
        let robotCollectionRef = db.collection("robots")
        
        // Query for the robot with the given serial number
        let querySnapshot = try await robotCollectionRef
            .whereField("serialNumber", isEqualTo: serialNumber)
            .getDocuments()
        
        // If there are any matching documents, the robot exists
        return !querySnapshot.isEmpty
    }
}

