//
//  SignUpViewModel.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/13/23.
//
import Foundation
import SwiftUI
//import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegistrationViewModel: ObservableObject {
    
    @Published var registrationError: String?
    @Published var registrationSuccess: Bool = false
    @State private var errorMessage = ""
    @Published var resetPasswordError: String?
    @Published var isPasswordResetEmailSent = false
    
    func registerUser(fullname: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.registrationError = "Registration failed: \(error.localizedDescription)"
                completion(error)
            } else {
                // Registration successful
                self.sendVerificationEmail()
                self.createTemporaryUserData(fullname: fullname, email: email, password: password)
                completion(nil)
            }
        }
    }
    
    private func sendVerificationEmail() {
        if let user = Auth.auth().currentUser {
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://geournal.page.link")
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            
            user.sendEmailVerification(with: actionCodeSettings) { error in
                if let error = error {
                    print("Error sending verification email: \(error.localizedDescription)")
                } else {
                    print("Verification email sent successfully.")
                }
            }
        }
    }
    
    private func createTemporaryUserData(fullname: String, email: String, password: String) {
        guard let tempUID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("temp_users").document(tempUID).setData([
            "fullname" : fullname,
            "email": email,
            //"password": password,
            //"verified": false,
            "data": []  // Initialize with an empty array for messages
            // Add any additional temporary user data you want to store
        ]) { error in
            if let error = error {
                self.registrationError = "Temporary user data creation failed: \(error.localizedDescription)"
            } else {
                // Temporary user data creation successful
                self.registrationError = nil
                self.registrationSuccess = true  // Set success flag
            }
        }
    }
    /*
    func checkIfEmailAuthorized() {
        if verified == true
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            // Email is verified, move user data
            print(user.isEmailVerified)
            let uid = user.uid
            moveUserDataFromTempToMain(uid: uid)
        } else {
            print("Error: User email not verified.")
        }
    }
     */
     func checkIfEmailAuthorized(completion: @escaping () -> Void) {
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            let uid = user.uid
            
            // Check if the user data has already been moved
            Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
                if let error = error {
                    print("Error checking user data: \(error.localizedDescription)")
                } else if document?.exists == true {
                    print("User data already moved.")
                    completion()
                    // You may want to handle this case as needed
                } else {
                    // User data hasn't been moved, so move it
                    self.moveUserDataFromTempToMain(uid: uid)
                    completion()
                }
            }
        } else {
            print("Error: User email not verified.")
        }
    }
    
    
     private func moveUserDataFromTempToMain(uid: String) {
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            Firestore.firestore().collection("temp_users").document(uid).getDocument { (document, error) in
                if let error = error {
                    print("Error retrieving temporary user data: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    let data = document.data() ?? [:]
                    Firestore.firestore().collection("users").document(uid).setData(data) { error in
                        if let error = error {
                            print("Error moving data to main collection: \(error.localizedDescription)")
                        } else {
                            Firestore.firestore().collection("temp_users").document(uid).delete { error in
                                if let error = error {
                                    print("Error deleting temporary user data: \(error.localizedDescription)")
                                } else {
                                    print("Temporary user data deleted successfully.")
                                }
                            }
                        }
                    }
                }
            }
        } else {
            print("User email not verified yet.")
            // Handle this case, such as prompting the user to verify their email.
        }
    }
    
    func resetPassword(forEmail email: String) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    // Handle error
                    self.resetPasswordError = "Password reset failed: \(error.localizedDescription)"
                } else {
                    // Password reset email sent successfully
                    self.isPasswordResetEmailSent = true
                }
            }
        }
}
