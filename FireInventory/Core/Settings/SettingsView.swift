//
//  SettingsView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/10/24.
//

import SwiftUI


struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var confirmDelete = false
    
    var body: some View {
        List {
            Button("Log Out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password Reset!")
                    } catch {
                        print(error)
                    }
                }
            }
            Button("Delete User Account") {
                confirmDelete.toggle()
            }
        }
        .navigationTitle("Settings")
        .alert("Are you sure you want to Delete Account", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteUserAccount()
                    showSignInView = true
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}
