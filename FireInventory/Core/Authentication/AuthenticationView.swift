//
//  AuthenticationView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/10/24.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            
            Spacer()
            
            NavigationLink {
                EmailSignInView(showSignInView: $showSignInView)
                    .background(Color.appBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundStyle(Color.deepBlue)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.neonGreen)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("ITA")
        .background(Color.appBackgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
