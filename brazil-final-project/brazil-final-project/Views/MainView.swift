//
//  MainView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/25/23.
//

import Foundation
import SwiftUI
import MapKit

extension Color {
    static let lightDark = Color(red: 0.1, green: 0.1, blue: 0.1) // Slightly lighter than pure black - for dark mode compatability
}

struct MainView: View {
    var name: String
    
    @State private var selectedTab = 1 // start on home view
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        VStack {
        
            TabView (selection: $selectedTab) {
                
                    
                    HomePageView(name: name,selectedTab: $selectedTab)
                        .tabItem { Label("Home", systemImage: "house") }
                        .tag(1)
                        .environmentObject(healthManager)
                    
                    allEntriesView()
                        .tabItem { Label("Calendar", systemImage: "calendar") }
                        .tag(2)
                    
                    AllEntriesMapView()
                        .tabItem { Label("Map", systemImage: "map.fill") }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape") }
                        .tag(4)
                    
                    
                }
                .accentColor(Color("BrandColor"))
                .tabViewStyle(.automatic)
                
        
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}


#Preview {
    MainView(name: "Friend")
}
