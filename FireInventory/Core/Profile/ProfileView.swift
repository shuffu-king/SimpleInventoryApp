//
//  ProfileView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/11/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws{
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        //        self.user = try await UserManager.shared.getUser(id: authDataResult.uid)
        self.user = try await UserManager.shared.getUser(id: authDataResult.uid)
        print(authDataResult)
    }
}


struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = viewModel.user {
                    if let name = user.name {
                        ProfileRowView(title: "Name", value: name)
                    }
                    
                    if let email = user.email {
                        ProfileRowView(title: "Email", value: email)
                    }
                } else {
                    ProgressView()
                }
                Spacer()
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackgroundColor.edgesIgnoringSafeArea(.all))
        }
        .task{
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
                            }
        }
    }
}

struct ProfileRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(title):")
                .font(.headline)
                .foregroundStyle(Color.offWhite)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.offWhite.opacity(0.7))
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
