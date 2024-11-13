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
    
    func getUser(id: String) async throws -> DBUser {
        try await userDocument(userId: id).getDocument(as: DBUser.self)
    }
    
    func deleteUser(id: String) async throws {
        // Delete Firestore document
        try await userDocument(userId: id).delete()
        
        // Delete from Firebase Authentication
        try await AuthenticationManager.shared.deleteCurrentUser()
    }
}
