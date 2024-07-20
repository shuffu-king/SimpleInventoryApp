//
//  TabBarView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/17/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            NavigationStack {
                SitesView()
            }
            .tabItem {
                Image(systemName: "mappin.and.ellipse.circle")
                Text("Sites")
            }
            
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }

    }
}

#Preview {
    TabBarView(showSignInView: .constant(false))
}
