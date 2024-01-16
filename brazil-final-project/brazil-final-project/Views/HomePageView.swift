//
//  HomePageView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/9/23.
//

import Foundation
import SwiftUI
import MapKit


struct HomePageView: View {
    
    @StateObject var viewModel: DataViewModel = DataViewModel()
    @ObservedObject var locationManager: LocationManager = LocationManager()
    
    var name: String
    
    @State private var isDataLoaded = false
    @State private var annotations: [MKAnnotation] = []
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
   
    // Sample coordinates for the path on the map
    @State private var coordinates: [CLLocationCoordinate2D] = []
    @AppStorage("colorScheme") private var colorScheme = 0
    @AppStorage("fontSize") private var fontSize = 0.0
    
    @EnvironmentObject var healthManager: HealthManager
    
    @Binding var selectedTab: Int

    var body: some View {
        
        
        NavigationStack {
            ZStack {
                VStack {
                    // Title section
                    HStack {
                        
                        Text(String(format: "%@%@%@", "Hi ", name, "!"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: CGFloat(fontSize+24)))
                            .bold()
                            .textCase(.uppercase)
                    }
                    
                    Text("How are you today?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: CGFloat(fontSize+24)))
                        .bold()

                    
                    if (healthManager.todayStepCount != "") {
                        Text(String(format: "%@%@%@", "Today you walked ", healthManager.todayStepCount, " steps!"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: CGFloat(fontSize+18)))
                            .foregroundColor(.gray)
                            .padding([.top], 1)
                    }
                    
                    ScrollView {
                        
                        LocationMapView(locationManager: locationManager)
                            .frame(height: 300)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding([.top, .bottom])
                            .onAppear(){
                                locationManager.startUpdatingLocation()
                            }
                        
                        NavigationLink {
                            SingleEntryDetailView(viewModel: viewModel, locationManager: locationManager, isEditMode: true, fixedDate: Date())
                                .edgesIgnoringSafeArea(.top)
                        } label: {
                            Label("Add entry", systemImage: "square.and.pencil")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: CGFloat(fontSize+18)))
                                .padding()
                                .foregroundColor(.white)
                        }
                        .background(Color("BrandColor"))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                        .padding([.top], 50)
                        
                        
                        
                        NavigationLink {
                            detailView(viewModel: viewModel, locationManager:locationManager,date: Date())
                                .edgesIgnoringSafeArea(.top)
                        } label: {
                            Label("Today's entries", systemImage: "book.pages")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.system(size: CGFloat(fontSize+18)))
                                .padding()
                                .foregroundColor(.white)
                        }
                        .background(Color("BrandColor"))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                        .padding([.top], 10)
                        
                        
                    }
                    Spacer()
                    
                }
                .onAppear{
                    DispatchQueue.main.async{
                        self.isDataLoaded = false
                        viewModel.fetchDataForCurrentUser(){
                            self.isDataLoaded = true
                        }
                    }
                }
                .padding(30)
            }
            .preferredColorScheme(colorScheme == 0 ? .light : .dark)
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            selectedTab = 1
            healthManager.fetchTodaySteps()
        }
    }
    }


//#Preview {
//    HomePageView(name: "friend")
//}

//
//    func hardCodedAnnotations() {
//        // Remove existing overlays
//        overlays.removeAll()
//        annotations.removeAll()
//
////        let a1 = MKPointAnnotation()
////        a1.coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
////        annotations.append(a1)
//
//        let c1 = CLLocationCoordinate2D(latitude: 40.80688585630468, longitude: -73.96103735835264)
//        let c2 = CLLocationCoordinate2D(latitude: 40.80777102123656, longitude: -73.96383758449491)
//        coordinates = [c1, c2]
//
//        // Append the hardcoded annotations to the coordinates array
//        //coordinates = [a1, a2, a3, a4, a5, a6].map { $0.coordinate }
//
//      //   Append other annotations from entriesForSelectedDate
//
//        //DispatchQueue.main.async{
//            if let region = regionToFitCoordinates() {
//                self.region = region
//            }
//
//    }


//    private func regionToFitCoordinates() -> MKCoordinateRegion? {
//        guard let firstCoordinate = coordinates.first else { return nil }
//
//        var minLat = firstCoordinate.latitude
//        var maxLat = firstCoordinate.latitude
//        var minLon = firstCoordinate.longitude
//        var maxLon = firstCoordinate.longitude
//
//        for coordinate in coordinates {
//            minLat = min(minLat, coordinate.latitude)
//            maxLat = max(maxLat, coordinate.latitude)
//            minLon = min(minLon, coordinate.longitude)
//            maxLon = max(maxLon, coordinate.longitude)
//        }
//
//        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
//        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.2, longitudeDelta: (maxLon - minLon) * 1.2)
//
//        return MKCoordinateRegion(center: center, span: span)
//    }
//
