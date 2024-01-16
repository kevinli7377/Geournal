//
//  allEntriesView.swift
//  brazil-final-project
//
//  Created by Kevin Li on 11/13/23.
//

import Foundation
import SwiftUI
import FirebaseAuth

// View takes in 1 thing:
// 1. DataViewModel

struct allEntriesView: View {
    
    @StateObject var viewModel:DataViewModel = DataViewModel()
    @StateObject var locationManager:LocationManager = LocationManager()
    
    @State private var selectedDate: Date?
    @State private var navigationToDetail = false
    @State private var isDataLoaded = false
    
    @State private var decoratedDates: Set<DateComponents> = []
    @AppStorage("fontSize") private var fontSize = 0.0
    

    
    // Below for testing purpose only
    @State private var isLoggedIn: Bool = false
    
    private func signInUser() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        print(currentUserID)
        if let _ = Auth.auth().currentUser {
            // User is already signed in
            isLoggedIn = true
        } else {
            // Perform sign-in logic (replace with your authentication logic)
            Auth.auth().signIn(withEmail: "kl3285@columbia.com", password: "123456") { authResult, error in
                if let error = error {
                    // Handle sign-in error
                    print("Sign-in error: \(error.localizedDescription)")
                } else {
                    print("signedIn")
                    // Sign-in successful
                    isLoggedIn = true
                }
            }
        }
    }
    // ----------------------------------------------
    
    // Function to get day from Date object
    func getDay(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    // Function to convert DateComponenet to Date
    func convertToDate(from dateComponents: DateComponents?) -> Date? {
        guard let dateComponents = dateComponents else { return nil }
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)
    }
    
    // New function to handle date selection
    private func handleDateSelection(_ dateComponents: DateComponents?) {
        if let dateComponents = dateComponents,
           let date = self.convertToDate(from: dateComponents) {
            DispatchQueue.main.async {
                self.selectedDate = date
                self.navigationToDetail = true
            }
        }
    }
    
    // ---------------VIEW--------------------
    var body: some View {
        NavigationStack{
            VStack{
                VStack(alignment:.leading){
                    Text("CALENDAR")
                        .font(.system(size: CGFloat(fontSize+24)))
                        .bold()
                    
                    Text("Pick a day to view Geournal entry.")
                        .font(.system(size: CGFloat(fontSize+18)))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading,30)
//                .padding(.trailing)
                    .padding(.top,30)
                
                // Calendar
                HStack{
                    Spacer()
                    if isDataLoaded{
                        CalendarView(decoratedDates: decoratedDates, onDateSelected: handleDateSelection)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("BrandColor"), lineWidth: 2) // Set the border color and width
                            )
                            .padding(.top,30)
                            .frame(width: 300, height: 300)
                            .scaleEffect(0.85)
                    } else {
                        ProgressView("Loading...")
                    }
                    
                    
                    Spacer()
                }
                .padding(.top, 100)
                Spacer()
                
            }
            .onAppear{
                self.isDataLoaded = false
                viewModel.fetchDataForCurrentUser(){
                    self.isDataLoaded = true
                    self.decoratedDates = viewModel.decoratedDates
                }
            }
            .navigationDestination(isPresented: $navigationToDetail){
                if let date=selectedDate{
                    detailView(viewModel: viewModel, locationManager: locationManager, date: date)
                }
            }
        }
    }
    
}
