//
//  UserManager.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/11/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable {
    let id: String
    let email: String?
    let name: String?
    let photoURL: String?
    let dateCreated: Date?
    
    init(auth: AuthDataResultModel) {
        self.id = auth.uid
        self.email = auth.email
        self.name = auth.name
        self.photoURL = auth.photoURL
        self.dateCreated = Date()
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {  }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy =  .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy =  .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.id).setData(from: user, merge: false, encoder: encoder)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "id": auth.uid,
//            "date_created": Timestamp(),
//        ]
//        if let photoURL = auth.photoURL {
//            userData["photo_url"] = photoURL
//        }
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let name = auth.name {
//            userData["name"] = name
//        }
//        
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//        
//    }
    
    func getUser(id: String) async throws -> DBUser {
        try await userDocument(userId: id).getDocument(as: DBUser.self)
    }
    
    
    
//    func getUser(id: String) async throws  -> DBUser {
//        let snapshot = try await userDocument(userId: id).getDocument()
//        
//        guard let data = snapshot.data(), let id = data["id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        
//        let email = data["email"] as? String
//        let name = data["name"] as? String
//        let photoURL = data["photoURL"] as? String
//        let dateCreated = data["date_created"] as? Date
//        
//        return DBUser(id: id, email: email, name: name, photoURL: photoURL, dateCreated: dateCreated)
//    }
    
}
