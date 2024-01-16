//
//  SingleEntryDetailView.swift
//  brazil-final-project
//
//  Created by Kevin Li on 11/14/23.
//
import Foundation
import SwiftUI
import MapKit

import CoreLocation
import FirebaseAuth
import FirebaseFirestore

struct SingleEntryDetailView: View {
    
    @AppStorage("colorScheme") private var colorScheme = 0 // For dark mode compatability
    
    // Passed arguments
    @ObservedObject var viewModel: DataViewModel;
    @ObservedObject var locationManager: LocationManager;
    
    @State var entry: DataModel?
    @State var isEditMode: Bool = false
    let fixedDate: Date
    
    @State private var isLoggedIn: Bool = false
    
    @State private var inputImage: UIImage?
    @State private var showingImagePicker: Bool = false
    @State private var truncatedFilename: String?
    
    // Variables to render on UI
    @State var description: String = ""
    @State var dateTime: Date = Date()
    @State var imgsrc : String = ""
    @State var addressString: String = ""
    @State var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Default for closure
    
    @State private var isEditingDone = false
    @State private var selectedDateTime: Date = Date()
    @State private var annotations: [MKAnnotation] = []// looks like the issue is here
    @State var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
    
    @State private var isImagePresented: Bool = false
    
    @AppStorage("fontSize") private var fontSize = 0.0
    
    @State private var showingLocationPicker = false;
    
    @State private var manuallyPickedLocation: CLLocationCoordinate2D?
    
    
    // ------------ HELPER FUNCTIONS ---------------
    
    func getAnnotation() {
        
        unwrapEntryProperties()
        annotations.removeAll()
        let a1 = MKPointAnnotation()
        a1.coordinate = location
        annotations.append(a1)
        self.region = MKCoordinateRegion(center: a1.coordinate,
                                         span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    func unwrapEntryProperties() {
        if let entry = entry {
            self.dateTime = entry.timestamp?.dateValue() ?? Date()
            self.description = entry.content
            self.imgsrc = entry.imageURL ?? ""
            self.location = entry.location != nil ? CLLocationCoordinate2D(latitude: entry.location!.latitude, longitude: entry.location!.longitude) : CLLocationCoordinate2D(latitude: 0, longitude: 0)
            convertCoordinatesToLocation(coordinate: self.location)
        } else {
            // Set default values for new entry
            self.dateTime = Date()
            self.description = ""
            self.imgsrc = ""
            
            if let currentLocation = locationManager.currentLocation?.coordinate {
                self.location = currentLocation
                convertCoordinatesToLocation(coordinate: self.location)
            } else {
                self.location = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Default value or another fallback
                self.addressString = "Location not available"
            }
        }
    }
    
    // Button action for 'Done'
    func handleDoneAction() {
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDateTime)
        let minute = calendar.component(.minute, from: selectedDateTime)
        dateTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: fixedDate) ?? fixedDate
        
        
        
        isEditMode.toggle()
        
        
        if let entry = entry {
            viewModel.editData(dataItem: entry, newContent: description, selectedDate: dateTime, newImage: inputImage, manuallyPickedLocation: manuallyPickedLocation){ error in
                viewModel.fetchDataForCurrentUser {
                }
                
            }
        } else {
            // Add new entry
            viewModel.sendData(content: description, image: inputImage, date: dateTime, manuallyPickedLocation: manuallyPickedLocation) { error in
                viewModel.fetchDataForCurrentUser {
                }
                
            }
        }
    }
    
    func convertCoordinatesToLocation(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else {
                print("Error in reverse geocoding: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let address = """
            \(placemark.thoroughfare ?? "Unknown street"),
            \(placemark.locality ?? "Unknown city"),
            \(placemark.country ?? "Unknown country")
            """
            
            self.addressString = address
            self.addressString = self.addressString.replacingOccurrences(of: "\n", with: " ")
        }
    }
    
    // To load URL image to input image
    func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.inputImage = uiImage
                }
            } else {
                print("Could not load image from URL: \(urlString)")
            }
        }.resume()
    }
    
    // Function to get day from Date object
    func getDay(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    // Function to get day from Date object
    func getTime(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: date)
    }
    
    // -------------------VIEW----------------------
    var body: some View {
        
        VStack{
            // Map view
            Spacer()
            MapViewJustAnnotations(annotations: $annotations, region: $region)
                .frame(height: 200)
                .cornerRadius(15)
                .padding(15)
                .onAppear(){
                    getAnnotation()
                }
            
            VStack(alignment: .leading) {
                
                ScrollView{
                    
                    if isEditMode{
                        HStack{
                            Spacer()
                                Button(action : {
                                    handleDoneAction()
                                }) {
                                    VStack{
                                        Text("Done")
                                            .foregroundColor(Color("BrandColor"))
                                            .font(.system(size: CGFloat(fontSize+12)))
                                    }
                                }
                            .padding()
                            .padding(.bottom, -25)
                            
                        }
                        VStack(alignment:.leading){
                            
                            HStack{
                                Spacer()
                                // Display date here:
                                
                                Text(getDay(date: fixedDate))
                                    .foregroundColor(colorScheme == 1 ?.white:Color.black)
                                
                                DatePicker("",selection: $selectedDateTime, displayedComponents: [.hourAndMinute])
                                    .onChange(of: selectedDateTime){
                                        let calendar = Calendar.current
                                        let hour = calendar.component(.hour, from: selectedDateTime)
                                        let minute = calendar.component(.minute, from: selectedDateTime)
                                        selectedDateTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: fixedDate) ?? fixedDate
                                    }
                                Spacer()
                            }
                            .padding()
                            
                            HStack(){
                                
                                Image(systemName: "location.fill")
                                    .foregroundColor(.red)
                                
                                Button(action: {
                                    showingLocationPicker = true
                                }) {
                                    Text("\(addressString)")
                                        .font(.system(size: CGFloat(fontSize + 12)))
                                        .foregroundColor(colorScheme == 1 ? .gray : .black)
                                }
                                .sheet(isPresented: $showingLocationPicker) {
                                            LocationPickerView(selectedLocation: $location) { newLocation in
                                                self.manuallyPickedLocation = newLocation
                                                self.location = newLocation
                                                self.convertCoordinatesToLocation(coordinate: newLocation)
                                                DispatchQueue.main.async {
                                                            self.annotations = [MKPointAnnotation(__coordinate: newLocation)]
                                                            self.region = MKCoordinateRegion(
                                                                center: newLocation,
                                                                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                                                            )
                                                        }
                                            }
                                        }
                                
                                
                            }
                            .padding()
                            .padding(.top, -10)
                            
                            HStack{
                                Spacer()
                                // Allow user to uplaod image
                                Button(action: {
                                    self.showingImagePicker = true
                                }) {
                                    // Image to display
                                    if let uiImage = inputImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(width: 75, height: 75)
                                            .cornerRadius(10)
                                            .saturation(isEditMode ? 0.5 : 1) // Saturation is reduced when in edit mode
                                            .overlay(isEditMode ? Image(systemName: "pencil").resizable().frame(width: 20,height: 20).foregroundColor(.white) : nil) // Edit icon when in edit mode
                                            .padding()
                                    } else {
                                        // Placeholder if no image is available
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2)) // Gray background
                                            .frame(width: 75, height: 75)
                                            .cornerRadius(10)
                                            .overlay(
                                                Image(systemName: "photo") // Placeholder image icon
                                                    .foregroundColor(colorScheme == 1 ?.gray:Color.white)
                                                    .font(.system(size: 40))
                                            )
                                            .padding()
                                    }
                                }
                                .sheet(isPresented: $showingImagePicker) {
                                    ImagePicker(image: $inputImage, isImagePickerPresented: $showingImagePicker, truncatedFilename: $truncatedFilename)
                                }
                                Spacer()
                                
                                // Allow user to change description
                                TextField("\(description)", text:$description, axis:.vertical)
                                    .font(.system(size: CGFloat(fontSize+14)))
                                    .foregroundStyle(.gray)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(8, reservesSpace:true)
                            }
                            
                        }
                        
                        // Not edit mode
                    } else {
                        HStack{
                            Spacer()
                            Button(action : {
                                isEditMode.toggle()
                            }) {
                                VStack{
                                    Image(systemName: "pencil")
                                        .foregroundColor(Color("BrandColor"))
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, -25)
                        
                        
                        VStack(alignment:.leading){
                            VStack(alignment:.leading){
                                Text(getTime(date:dateTime))
                                Text(getDay(date:dateTime))
                            }
                            .font(.system(size: CGFloat(fontSize+24)))
                            .bold()
                            .foregroundColor(colorScheme == 1 ?.white:Color.black)
                            .padding()
                            
                            HStack(){
                                Image(systemName: "location.fill")
                                    .foregroundColor(.red)
                                Text("\(addressString)")
                                    .font(.system(size: CGFloat(fontSize+12)))
                                    .foregroundColor(colorScheme == 1 ?.gray:Color.black)
                            }
                            .padding()
                            
                            HStack {
                                if description.isEmpty {
                                    Spacer() // This will push the image to the center if there is no text.
                                    if let uiImage = inputImage {
                                        Button(action: {
                                            self.isImagePresented = true
                                        }) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(10)
                                                .padding()
                                        }
                                        .sheet(isPresented: $isImagePresented) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .padding()
                                                .onTapGesture {
                                                    self.isImagePresented = false
                                                }
                                        }
                                    } else {
                                        // Placeholder if no image is provided
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                            .opacity(0.2)
                                    }
                                    Spacer() // This will push the image to the center if there is no text.
                                } else {
                                    if let uiImage = inputImage {
                                        Button(action: {
                                            self.isImagePresented = true
                                        }) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                                .cornerRadius(10)
                                                .padding()
                                        }
                                        .sheet(isPresented: $isImagePresented) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .padding()
                                                .onTapGesture {
                                                    self.isImagePresented = false
                                                }
                                        }
                                    } else {
                                        // Placeholder if no image is provided
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                            .opacity(0.2)
                                    }
                                    Text(description)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: CGFloat(fontSize+14)))
                                }
                            }
                        }
                    }
                }
            }.frame(height: 350)
                .padding(20)
                .background(colorScheme == 1 ? Color.lightDark : Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(15)
        }.onAppear{
            unwrapEntryProperties()
            convertCoordinatesToLocation(coordinate: location)
            loadImageFromURL(imgsrc)
        }
    }
}


