//
//  VerificationView.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/14/23.
//

import SwiftUI

struct VerificationView: View {
    @ObservedObject var userData: UserData
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("Geournal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color("BrandColor"))
                    .padding(.bottom, -50)
                
                Spacer()
                
                Text("Check Your Email")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    .foregroundColor(Color("BrandColor"))
                
                Text("We've sent a verification link to your email. Please check your inbox and click on the link to complete the registration process.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                    .foregroundColor(Color("BrandColor"))
                
                NavigationLink(destination: LoginView(userData: userData)){
                    // Redirect to the login screen
                    
                    Text("Go to Login")
                        .frame(width: 180, height: 45)
                        .background(Color("BrandColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.navigationTransition(.newSlide)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        VerificationView(userData: userData)
    }
}

