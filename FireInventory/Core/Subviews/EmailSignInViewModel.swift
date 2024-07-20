//
//  EmailSignInViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/11/24.
//

import Foundation

final class EmailSignInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email/password found.")
            return 
        }
        
        let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: returnedUserData)
//        try await UserManager.shared.createNewUser(auth: returnedUserData)
        try await UserManager.shared.createNewUser(user: user)
        
        print("success")
        print(returnedUserData)

    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email/password found.")
            return
        }
        
        let returnedUserData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        print("success")
        print(returnedUserData)

    }
    
}
