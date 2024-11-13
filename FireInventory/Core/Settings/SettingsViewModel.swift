//
//  SettingsViewModel.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/11/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func deleteUserAccount() async {
        do {
            if let userId = AuthenticationManager.shared.getCurrentUserId() {
                try await UserManager.shared.deleteUser(id: userId)
                print("User account deleted successfully.")
            }
        } catch {
            print("Error deleting user account: \(error.localizedDescription)")
        }
    }
    
}
