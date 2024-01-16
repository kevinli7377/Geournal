//
//  ForgotPasswordView.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/15/23.
//

import Foundation
import SwiftUI
struct ForgotPasswordView: View {
    @StateObject private var registrationViewModel = RegistrationViewModel()
    
    @ObservedObject var userData: UserData

    var body: some View {
        NavigationStack{
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
                            
                    }
                }
                .padding(.leading,10)
                .padding(.bottom, 50)
                
                Image("Geournal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(.bottom, -200)
                    .foregroundColor(Color("BrandColor"))
                
                Spacer()
                Text("Please enter your email for a password reset link.")
                    .font(.system(size: 16))
                    .foregroundColor(Color("BrandColor"))
                
                TextField("Email", text: $userData.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    registrationViewModel.resetPassword(forEmail: userData.email)
                }) {
                    Text("Reset Password")
                        .frame(width: 180, height: 45)
                        .background(Color("BrandColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Display an alert if there is a reset password error
                if let error = registrationViewModel.resetPasswordError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Display a success message if the password reset email was sent
                if registrationViewModel.isPasswordResetEmailSent {
                    Text("Password reset email sent successfully. Please check your inbox and spam folder. If you don't receive an email within five minutes, please verify you inputted a valid email.")
                        .foregroundColor(.green)
                        .padding()
                }
                
                Spacer()
            }
        }.navigationTransition(.newSlide)
        .navigationBarBackButtonHidden(true)
    }
}
/*
struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        ForgotPasswordView(userData: userData)
    }
}
*/
