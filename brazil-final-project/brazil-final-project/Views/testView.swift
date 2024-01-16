//
//  testView.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/20/23.
//

import Foundation
import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct TestView: View {
    @StateObject private var viewModel = DataViewModel()
    @State private var isLoggedIn: Bool = false
    
    private func signInUser() {
            // Check if there's a current user (already signed in)
           
                // Perform sign-in logic (replace with your authentication logic)
                Auth.auth().signIn(withEmail: "ari@gmail.com", password: "123456") { authResult, error in
                    if let error = error {
                        // Handle sign-in error
                        print("Sign-in error: \(error.localizedDescription)")
                    } else {
                        // Sign-in successful
                        guard let currentUserID = Auth.auth().currentUser?.uid else {
                            print("User not logged in.")
                            return
                        }
                        print("\(currentUserID)")
                        print("This is where we are")
                        isLoggedIn = true
                
            }
        }
    }
    
    
    var body: some View {
            VStack {
                if let firstData = viewModel.data.first {
                    Text("ID: \(firstData.id)")
                    Text("Sender ID: \(firstData.senderID)")
                    Text("Content: \(firstData.content)")

                    if let location = firstData.location {
                        let latitude = location.latitude
                        let longitude = location.longitude
                        Text("Latitude: \(latitude), Longitude: \(longitude)")
                    }

                    if let imageURL = firstData.imageURL, let url = URL(string: imageURL) {
                        // Display image from imageURL using SDWebImage
                        WebImage(url: url)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100) // Adjust size as needed
                    }
                } else {
                    Text("No data found.")
                }
            }
        .onAppear {
            // Fetch data for the current user from Firebase on view appear
            signInUser()
            viewModel.fetchDataForCurrentUser(){}
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
