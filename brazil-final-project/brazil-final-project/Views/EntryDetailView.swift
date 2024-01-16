//
//  EntryDetailView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/9/23.
//

import Foundation
import SwiftUI
import MapKit

struct detailView: View {
    
    @AppStorage("colorScheme") private var colorScheme = 0
    
    // Final view model arguments:
    @ObservedObject var viewModel: DataViewModel;
    @ObservedObject var locationManager: LocationManager;
    @State private var annotations: [MKAnnotation] = []
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
    )
    
    @State private var coordinates: [CLLocationCoordinate2D] = []
    @State var date: Date;
    //  @State private var isAnnotations = false
    
    var entriesForSelectedDate: [DataModel]{
        viewModel.searchDataByDate(date)
    }
    
    @State private var isEditMode: Bool = false
    
    @State private var selected: Bool = false // testing purposed only
    @State private var areAnnotationsPopulated = false
    
    @AppStorage("fontSize") private var fontSize = 0.0
    
    // Function to get day from Date object
    func getDay(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // Example format: "June 3, 2023"
        return dateFormatter.string(from: date)
    }
    
    func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func getAnnotations() {
        // Remove existing overlays
        annotations.removeAll()
        annotations = []
        
        
        //   Append other annotations from entriesForSelectedDate
        for entry in entriesForSelectedDate {
            if let location = entry.location {
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let currAnnotation = MKPointAnnotation()
                currAnnotation.coordinate = coordinate
                annotations.append(currAnnotation)
                coordinates.append(currAnnotation.coordinate)
            }
        }
        
        DispatchQueue.main.async {
            if let region = regionToFitAnnotations() {
                self.region = region
            }
        }
        
        areAnnotationsPopulated = !annotations.isEmpty //update to indicate whether annotations are now populated
    }
    
    
    private func regionToFitAnnotations() -> MKCoordinateRegion? {
        guard let firstAnnotation = annotations.first else { return nil }
        
        var minLat = firstAnnotation.coordinate.latitude
        var maxLat = firstAnnotation.coordinate.latitude
        var minLon = firstAnnotation.coordinate.longitude
        var maxLon = firstAnnotation.coordinate.longitude
        
        for annotation in annotations {
            minLat = min(minLat, annotation.coordinate.latitude)
            maxLat = max(maxLat, annotation.coordinate.latitude)
            minLon = min(minLon, annotation.coordinate.longitude)
            maxLon = max(maxLon, annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        // TODO: THIS IS CAUSING A CRASH ON CERTAIN COORDINATES BECAUSE THE MATH CAUSES AN INVALID COORDINATE
        let span = MKCoordinateSpan(latitudeDelta: /*(maxLat - minLat) **/ 3.0 + 1.0, longitudeDelta: /*(maxLon - minLon) **/ 3.0 + 1.0)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    
    var body: some View {
        NavigationStack{
            
            // Map view
            VStack{
                
               
                
            }
            
            VStack(){
                HStack(){
                    
                    Text(getDay(date:date))
                        .font(.system(size: CGFloat(fontSize+24)))
                        .bold()
                    
                    Spacer()
                    
                    
                }.padding(15)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(entriesForSelectedDate, id: \.id) { entry in
                            
                            NavigationLink(destination:
                                            SingleEntryDetailView(viewModel: viewModel,
                                                                  locationManager: locationManager,
                                                                  entry:entry,
                                                                  isEditMode:false,
                                                                  fixedDate:date)){
                                HStack {
                                    if isEditMode {
                                        Button(action: {
                                            //TODO: Should remove entry
                                            viewModel.deleteData(dataItem: entry){ _ in viewModel.fetchDataForCurrentUser{}}
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundStyle(.red)
                                        }.padding(.trailing, 5)
                                    }
                                    
                                    
                                    VStack(alignment: .leading) {
                                        
                                        Text(formatTime(entry.timestamp?.dateValue()))
                                            .font(.system(.subheadline))
                                            .foregroundColor(colorScheme == 1 ?.white:Color.black)
                                            .bold()
                                        
                                        Text(entry.content)
                                            .foregroundColor(colorScheme == 1 ?.gray:Color.black)
                                            .font(.system(.caption))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    if let imageURL = URL(string: entry.imageURL ?? "") {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .cornerRadius(10)
                                                
                                            case .failure(_):
                                                // Display a placeholder image or text if the image fails to load
                                                EmptyView()
                                                
                                            case .empty:
                                                // Display a placeholder or loader while the image is loading
                                                ProgressView()
                                                
                                            @unknown default:
                                                // Fallback for future cases
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        EmptyView()
                                    }
                                }
                                .frame(height:50)
                            }
                            Divider()
                        }
                        .padding()
                        .padding(.top, -10)
                        .padding(.bottom, -10)
                        //                        .foregroundStyle(.black)
                        
                        
                        if !isEditMode{
                            HStack{
                                Spacer()
                                NavigationLink(destination: SingleEntryDetailView(viewModel: viewModel,
                                                                                  locationManager: locationManager,
                                                                                  entry:nil,
                                                                                  isEditMode:true,
                                                                                  fixedDate:date)){
                                    
                                    Text("+ Add")
                                        .font(.system(size: CGFloat(fontSize+12)))
                                        .frame(width: 150, height: 35)
                                        .background(Color("BrandColor"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } .padding(.top, 10)
                                    .padding(.bottom, 10)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(height:450)
                //                .navigationBarBackButtonHidden(true)
                
                HStack {
                    // Previous Entry Button
                    Button(action: {
                        date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
                        DispatchQueue.main.async{
                            getAnnotations()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("BrandColor"))
                        Text(formatDate(Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date))
                            .font(.system(size: CGFloat(fontSize+12)))
                            .foregroundColor(Color("BrandColor"))
                    }
                    
                    Spacer()
                    
                    // Edit Current Entry Button
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        VStack{
                            if isEditMode {
                                Text("Done")
                                    .font(.system(size: CGFloat(fontSize+12)))
                                    .foregroundColor(Color("BrandColor"))
                            } else {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color("BrandColor"))
                                
                                Text("Edit")
                                    .font(.system(size: CGFloat(fontSize+12)))
                                    .foregroundColor(Color("BrandColor"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Next Entry Button
                    Button(action: {
                        date = Calendar.current.date(byAdding: .day, value: +1, to: date) ?? date
                        DispatchQueue.main.async{
                            getAnnotations()
                        }
                    }) {
                        Text(formatDate(Calendar.current.date(byAdding: .day, value: +1, to: date) ?? date))
                            .font(.system(size: CGFloat(fontSize+12)))
                            .foregroundColor(Color("BrandColor"))
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("BrandColor"))
                    }
                }
                .frame(height:30)
                
            }   .padding(15)
                .background(colorScheme == 1 ? Color.lightDark : Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(15)
        }
        .onAppear(){
            DispatchQueue.main.async{
                getAnnotations()
                areAnnotationsPopulated = true
            }
        }
        
        
        
    }
}

