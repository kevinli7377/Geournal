//
//  LogInView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/9/23.
//

import Foundation
import SwiftUI
import NavigationTransition
//import MapKit
import FirebaseAuth
import UIKit

class UserData: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
}

struct LoginView: View {
   // @State private var email: String = ""
  //  @State private var password: String = ""
    @StateObject var userData: UserData
    @State private var isPasswordVisible: Bool = false
    @ObservedObject var registrationViewModel = RegistrationViewModel()
    @ObservedObject var userViewModel = DataViewModel()
    @State private var errorMessage = ""
    @State private var isEmailVerified = false
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        NavigationStack {
            VStack {
                Image("Geournal")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("BrandColor"))
                    .frame(width: 250, height: 250)
                    .padding(.top, 50)
                
                HStack {
                    TextField("Email", text: $userData.email)
                        .padding(.top, 40)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .font(.system(size: 16))
                        .frame(width: 300, alignment: .center)
                }
                
                HStack {
                    if isPasswordVisible {
                        ZStack(alignment: .trailing) {
                            TextField("Password", text: $userData.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .font(.system(size: 16))
                                .frame(width: 300, alignment: .center)
                            
                            // if password.isEmpty {
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Text(isPasswordVisible ? "Hide" : "Show")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color("BrandColor"))
                                    .padding(.trailing, 8)
                            }
                            .transition(.opacity) // Add a transition
                            //}
                        }
                    } else {
                        ZStack(alignment: .trailing) {
                            SecureField("Password", text: $userData.password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .font(.system(size: 16))
                                .frame(width: 300, alignment: .center)
                            
                            // if password.isEmpty {
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Text(isPasswordVisible ? "Hide" : "Show")
                                    .font(.system(size:16))
                                    .foregroundColor(Color("BrandColor"))
                                    .padding(.trailing, 8)
                            }
                            .transition(.opacity) // Add a transition
                            //}
                        }
                    }
                }
                .padding(.top, 10)
                NavigationLink(destination: ForgotPasswordView(userData: userData)){
                    Text("Forgot Password?")
                        .font(.system(size: 14))
                        .foregroundColor(Color("BrandColor"))
                        .underline()
                        .padding(.top,40)
                }
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .opacity(errorMessage.isEmpty ? 0 : 1)
                
                Button(action: {
                    
                    Auth.auth().signIn(withEmail: userData.email, password: userData.password) { authResult, error in
                        if let error = error {
                            // Handle login failure
                            errorMessage = "Error: \(error.localizedDescription)"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                errorMessage = ""
                                                
                                            }
                                        }
                        } else {
                            registrationViewModel.checkIfEmailAuthorized() {
                                self.isEmailVerified = true
                                authManager.isAuthenticated = true
                                userViewModel.getFullNameForCurrentUser{
                                  
                                    authManager.fullName = userViewModel.fullName ?? "Friend"
                                }
                                
                            }
                        }
                    }
                }) {
                    Text("Log In")
                        .font(.system(size:16))
                        .frame(width: 180, height: 45)
                        .background(Color("BrandColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                
                NavigationLink(destination: SignUpView(userData: userData)){
                    
                    
                    
                    Text("Don't have an account? Let's make one!")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 30)
                        .underline()
                        
                    
                }.scaleEffect(1.0)
                    
                
                Spacer()
            }
            .padding()
            
            .navigationBarBackButtonHidden(true)
            
        }
        .navigationTransition(.slide)
            
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
    
        let userData = UserData()
        
        LoginView(userData: userData)
    }
}

