//
//  SignUpView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/9/23.
//

import Foundation
import SwiftUI
import NavigationTransitions
//import Firebase
import FirebaseFirestore

struct SignUpView: View {
    @ObservedObject var userData: UserData
    @State private var full_name: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var showSheet = false
    @State private var confirmPassword: String = ""
    @ObservedObject var registrationViewModel = RegistrationViewModel()
    @State private var isVerificationViewActive = false
    @State private var errorMessage = ""
    @State private var errorMessageOpacity: Double = 1.0
    

    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    NavigationLink(destination: LoginView(userData: userData)){
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color("BrandColor"))
                            .font(.system(size: 14))
                        
                        
                        Text("Back")
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(Color("BrandColor"))
                            
                        
                        Spacer()
                            
                    }.navigationTransition(.newSlide)
                }
                .padding(.leading,10)
                
                HStack {
                    Text("Sign Up")
                        .font(.system(size: 32))
                        .bold()
                    Spacer()
                    
                    Image("Geournal_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundColor(Color("BrandColor"))
                }
                .padding(15)
                
                .navigationBarBackButtonHidden(true)
                
                VStack{
                    HStack {
                        TextField("Full Name", text: $full_name)
                            .padding(.top, 10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .font(.system(size: 14))
                            .frame(width: 300, alignment: .center)
                    }
                    
                    HStack {
                        TextField("Email", text: $userData.email)
                            .padding(.top, 10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .font(.system(size: 14))
                            .frame(width: 300, alignment: .center)
                    }
                    
                    HStack {
                        if isPasswordVisible {
                            ZStack(alignment: .trailing) {
                                TextField("Password", text: $userData.password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .font(.system(size: 14))
                                    .frame(width: 300, alignment: .center)
                                
                                // if password.isEmpty {
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Text(isPasswordVisible ? "Hide" : "Show")
                                        .font(.system(size: 14))
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
                                    .font(.system(size: 14))
                                    .frame(width: 300, alignment: .center)
                                
                                // if password.isEmpty {
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Text(isPasswordVisible ? "Hide" : "Show")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("BrandColor"))
                                        .padding(.trailing, 8)
                                }
                                .transition(.opacity) // Add a transition
                                //}
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    HStack {
                        if isPasswordVisible {
                            ZStack(alignment: .trailing) {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .font(.system(size: 14))
                                    .frame(width: 300, alignment: .center)
                            }
                        } else {
                            ZStack(alignment: .trailing) {
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .font(.system(size: 14))
                                    .frame(width: 300, alignment: .center)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.top,39)
                
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .opacity(errorMessage.isEmpty ? 0 : 1) // Apply opacity to the error message
                    
                
                Button(action: {
                    registrationViewModel.registerUser(fullname: full_name, email: userData.email, password: userData.password) { error in
                        if let error = error {
                            // Handle the registration error here
                            errorMessage = "Registration failed: \(error.localizedDescription)"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                errorMessage = ""
                                                
                                            }
                                        }
                        } else {
                            self.isVerificationViewActive = true
                        }
                    }
                        
                    
                    
                }) {
                    
                    
                    
                    Text("Sign up")
                        .frame(width: 150, height: 45)
                        .background(Color("BrandColor"))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .font(.headline)
                        .font(.system(size: 14))
                }
                .padding(.top, 40)
                    
                .navigationDestination(isPresented: $isVerificationViewActive) { VerificationView(userData: userData)
                     }.navigationTransition(.slide)
                
                
                Spacer()
            }//.navigationTransition(.newSlide)
            .navigationBarBackButtonHidden(true)
            .padding()
        }
       
        
        
    }
}



struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        SignUpView(userData: userData)
    }
}

