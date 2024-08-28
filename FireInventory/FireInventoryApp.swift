//
//  FireInventoryApp.swift
//  FireInventory
//
//  Created by Ayo Shafau on 7/10/24.
//

import SwiftUI
import Firebase

@main
struct FireInventoryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .background(Color.appBackgroundColor)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured Firebase!")
        return true
    }
}
