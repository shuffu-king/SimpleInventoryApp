//
//  EmailSignInView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/10/24.
//

import SwiftUI



struct EmailSignInView: View {
    
    @StateObject private var viewModel = EmailSignInViewModel()
    @Binding var showSignInView: Bool
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email....", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                SecureField("Password...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                Button {
                    Task {
                        if viewModel.email.isEmpty || viewModel.password.isEmpty {
                            showAlert.toggle()
                        } else {
                            do {
                                try await viewModel.signUp()
                                showSignInView = false
                            } catch {
                                print(error)
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    if viewModel.email.isEmpty || viewModel.password.isEmpty {
                        showAlert.toggle()
                    } else {
                        Task {
                            do {
                                try await viewModel.signIn()
                                showSignInView = false
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("IVA")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackgroundColor)
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert){
            Alert(title: Text("One or more fields missing"),
                  message: Text("Please ensure email and password have been entered correctly"), dismissButton: .cancel())
        }
    }
}

#Preview {
    EmailSignInView(showSignInView: .constant(false))
}
