//
//  brazil_final_projectApp.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 10/31/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

import MapKit

@main
struct DiaryAppApp: App {
    // State variable to track authentication status
    @StateObject var authManager = AuthManager()
    @ObservedObject var userData: UserData = UserData()
    @StateObject var healthManager = HealthManager()
    //@ObservedObject var userViewModel = DataViewModel()
    
    var name = "Friend"
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        let db = Firestore.firestore()
        db.settings = settings
    }
    

    var body: some Scene {
        WindowGroup {
          
            // Using a conditional view based on the authentication status
            if authManager.isAuthenticated {
               
                MainView(name: authManager.fullName ?? "Friend")
                               .environmentObject(authManager)
                               .environmentObject(healthManager)
                       } else {
                           LoginView(userData: userData)
                               .environmentObject(authManager)
                       }
        }
        
    }
}
