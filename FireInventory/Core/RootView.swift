//
//  RootView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/10/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                NavigationStack {
                    TabBarView(showSignInView: $showSignInView)
                }
            }
        }
        .background(Color.appBackgroundColor)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                EmailSignInView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
