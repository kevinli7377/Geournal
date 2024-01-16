//
//  AuthManager.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/29/23.
//

import Foundation
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoggedOut: Bool = false
    @Published var fullName: String?
    
    func logout() {

                // Perform any necessary logout tasks, such as clearing user data, tokens, etc.

                

                // Set isAuthenticated to false to switch to the login view

                isAuthenticated = false

                // Set isLoggedOut to true to trigger any necessary UI changes or actions

                isLoggedOut = true

                // Clear any user-related data

                fullName = nil

            }
}
