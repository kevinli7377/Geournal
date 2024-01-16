//
//  SettingsView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/25/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme = 0
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("fontSize") private var fontSize = 0.0
    
    var body: some View {
        
        VStack {
            Text("SETTINGS")
                .font(.system(size: CGFloat(fontSize+24)))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack {
                    
                    Text("Customize Geournal to fit you.")
                        .font(.system(size: CGFloat(fontSize+18)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    
                    Text("Adjust app color scheme.")
                        .font(.system(size: CGFloat(fontSize+18)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("", selection: $colorScheme) {
                        Text("Light").tag(0)
                        Text("Dark").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 30)
                    
                    
                    Text("Drag to change font size.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: CGFloat(fontSize+18)))
                    
                    Slider(value: $fontSize, in: 1...30)
                        .padding(.bottom, 30)
                    
                    
                }
                
            }
            
            Spacer()
            
            Button(action: {
                authManager.logout()
            }){
                
                Text("log out")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.system(size: CGFloat(fontSize+18)))
                    .padding()
                    .foregroundColor(.white)
            }
            .background(.gray)
            .cornerRadius(25)
            .shadow(radius: 5)
            .padding([.top], 50)
        }
        .preferredColorScheme(colorScheme == 0 ? .light : .dark)
        .padding(30)
    }
}

#Preview {
    SettingsView()
}
