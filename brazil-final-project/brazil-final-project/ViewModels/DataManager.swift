//
//  DataManager.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/11/23.
//

import Foundation
//import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit
import CoreLocation

class DataViewModel: ObservableObject {
    @Published var data: [DataModel] = []
    private var locationManager = LocationManager()
    @Published var filteredData: [DataModel] = []
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    @Published var fullName: String?
    @Published var decoratedDates: Set<DateComponents> = []
    @Published var isDataLoaded = false
    
//    init() {
//        DispatchQueue.main.async{
//            self.isDataLoaded = false
//            self.fetchDataForCurrentUser(){
//                self.isDataLoaded = true
//            }
//        }
//    }
    
    func reset() {
        data = []
        // Reset other properties if needed
    }
    
    // Fetch data for the logged-in user
    func fetchDataForCurrentUser(completion: @escaping () -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
        print("Fetching data for user ID: \(currentUserID)")
        
        db.collection("users").document(currentUserID).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("User document does not exist.")
                completion()
                return
            }
            
            print("Document data: \(document.data() ?? [:])")
            
            if let dataArray = document.data()?["data"] as? [[String: Any]] {
                let data = dataArray.map { dataItem in
                    var location: DataModel.Location? = nil
                    
                    if let locationData = dataItem["location"] as? [String: Double] {
                        location = DataModel.Location(
                            latitude: locationData["latitude"] ?? 0.0,
                            longitude: locationData["longitude"] ?? 0.0
                        )
                    }
                    
                    let timestamp = (dataItem["timestamp"] as? Timestamp) ?? Timestamp()
                    return DataModel(
                        id: dataItem["id"] as? String ?? "",
                        senderID: dataItem["senderID"] as? String ?? "",
                        content: dataItem["content"] as? String ?? "",
                        timestamp: timestamp,
                        imageURL: dataItem["imageURL"] as? String,
                        location: location
                    )
                }
                
                print("Fetched data: \(data)")
                
                DispatchQueue.main.async {
                    let sortedData = self.sortDataByTimestamp(data)
                    self.data = sortedData
                    print("Updated data in the ViewModel: \(self.data)")
                    
                    self.decoratedDates = self.getAllDecoratedDates()
                    print("dates",self.decoratedDates)
                    completion()
                }
            } else {
                print("No data found in the user document.")
                completion()
            }
        }
    }
    
    func sortDataByTimestamp(_ data: [DataModel]) -> [DataModel] {
        let sortedData = data.sorted { (item1, item2) -> Bool in
            if let date1 = item1.timestamp?.dateValue(), let date2 = item2.timestamp?.dateValue() {
                return date1 < date2
            }
            return false
        }
        
        return sortedData
    }
    
    func searchDataByDate(_ date: Date) -> [DataModel] {
        let results = data.filter { (item) -> Bool in
            // Assuming timestamp is of type Date, adjust accordingly
            guard let itemDate = item.timestamp?.dateValue() else {
                return false
            }
            
            // Compare the date components (day, month, and year)
            let calendar = Calendar.current
            let components1 = calendar.dateComponents([.year, .month, .day], from: itemDate)
            let components2 = calendar.dateComponents([.year, .month, .day], from: date)
            
            return components1 == components2
        }
        
        DispatchQueue.main.async{
            self.filteredData = results
        }
        
        return filteredData
    }
    
    
    // Function to send data
    func sendData(content: String, image: UIImage?, date: Date, manuallyPickedLocation: CLLocationCoordinate2D?, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        var dataItem: [String: Any] = [
            "id": UUID().uuidString,
            "senderID": currentUserID,
            "content": content,
            "timestamp": date
        ]
        
        // Check if an image is provided
        if let image = image {
            // Upload the image to Firebase Storage
            uploadImage(image) { imageURL, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Add the imageURL to the data item
                dataItem["imageURL"] = imageURL
                
                // Update Firestore with the data item
                self.updateFirestoreWithDataAndLocation(currentUserID, dataItem, manuallyPickedLocation: manuallyPickedLocation, completion)
            }
        } else {
            // No image provided, directly update Firestore
            updateFirestoreWithDataAndLocation(currentUserID, dataItem, manuallyPickedLocation: manuallyPickedLocation, completion)
        }
    }
    
    // Function to upload an image to Firebase Storage
    private func uploadImage(_ image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "", code: 401, userInfo: ["description": "User not logged in."]))
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = storage.reference().child("images/\(currentUserID)/\(imageName)")
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                guard let _ = metadata else {
                    completion(nil, error)
                    return
                }
                
                // Retrieve the download URL
                storageRef.downloadURL { url, error in
                    completion(url?.absoluteString, error)
                }
            }
        } else {
            completion(nil, NSError(domain: "", code: 500, userInfo: ["description": "Failed to convert image to data."]))
        }
    }
    
    // Function to update Firestore with the data item
    private func updateFirestoreWithData(_ currentUserID: String, _ dataItem: [String: Any], _ completion: @escaping (Error?) -> Void) {
        db.collection("users").document(currentUserID).updateData([
            "data": FieldValue.arrayUnion([dataItem])
        ]) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    private func updateFirestoreWithDataAndLocation(_ currentUserID: String, _ dataItem: [String: Any], manuallyPickedLocation: CLLocationCoordinate2D?, _ completion: @escaping (Error?) -> Void) {
        var updatedDataItem = dataItem
        
        // Check if a manually picked location is available, otherwise use the current location
        if let manualLocation = manuallyPickedLocation {
            updatedDataItem["location"] = [
                "latitude": manualLocation.latitude,
                "longitude": manualLocation.longitude
            ]
        } else if let location = locationManager.currentLocation {
            updatedDataItem["location"] = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]
        }
        
        db.collection("users").document(currentUserID).updateData([
            "data": FieldValue.arrayUnion([updatedDataItem])
        ]) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    func deleteImageFromStorage(imageURL: String, currentUserID: String) {
        // Extract the filename from the imageURL
        if let fileName = extractFileName(from: imageURL) {
            // Create a reference to the image in Firebase Storage
            let storageRef = Storage.storage().reference().child("\(fileName)")
            
            // Delete the image from Firebase Storage
            storageRef.delete { error in
                if let error = error {
                    print("Error deleting image from Firebase Storage: \(error.localizedDescription)")
                    // Handle the error as needed
                } else {
                    print("Image deleted successfully from Firebase Storage.")
                    // Perform any additional actions after successful deletion
                }
            }
        } else {
            print("Failed to extract filename from imageURL.")
            // Handle the failure to extract the filename as needed
        }
    }
    
    func extractFileName(from imageURL: String) -> String? {
        // Split the URL by "/"
        let components = imageURL.components(separatedBy: "/")
        
        // Find the last component and remove the query parameters
        if let lastComponent = components.last?.components(separatedBy: "?").first{
            // Decode the URL-encoded string
            if let decodedFileName = lastComponent.removingPercentEncoding {
                return decodedFileName
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func editData(dataItem: DataModel, newContent: String, selectedDate: Date, newImage: UIImage?, manuallyPickedLocation: CLLocationCoordinate2D?, completion: @escaping (Error?) -> Void) {
        // ... existing code ...
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        var updatedDataItem = [
            "id": dataItem.id,
            "senderID": dataItem.senderID,
            "content": newContent,
            "timestamp": selectedDate
            
        ] as [String : Any]
        /*
         if let location = locationManager.currentLocation {
         updatedDataItem["location"] = [
         "latitude": location.coordinate.latitude,
         "longitude": location.coordinate.longitude
         ]
         }
         */
        let db = Firestore.firestore()
        let collection = db.collection("users")  // Replace with your actual collection name
        let document = collection.document(currentUserID)
        
        // Fetch the document to get the current array of data
        document.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let document = document, document.exists else {
                // Handle the case when the document doesn't exist
                let documentNotExistError = NSError(domain: "YourAppDomain", code: 404, userInfo: nil)
                completion(documentNotExistError)
                return
            }
            
            // Get the current data array
            var dataArray = document.get("data") as? [[String: Any]] ?? []
            
            // Find the index of the data item with the specified ID
            if let indexToRemove = dataArray.firstIndex(where: { $0["id"] as? String == dataItem.id }) {
                // Remove the entry at the found index
                let imagetoDelete = dataArray[indexToRemove]["imageURL"] as? String
                self.deleteImageFromStorage(imageURL: imagetoDelete ?? "", currentUserID: currentUserID)
                dataArray.remove(at: indexToRemove)
                
                // Update Firestore with the modified array
                db.collection("users").document(currentUserID).updateData(["data": dataArray]) { error in
                    completion(error)
                }
            } else {
                // Handle the case when the ID is not found
                let idNotFoundError = NSError(domain: "YourAppDomain", code: 404, userInfo: nil)
                completion(idNotFoundError)
            }
        }

        // Check if a new image is provided
        if let newImage = newImage {
            // Upload the new image to Firebase Storage
            uploadImage(newImage) { imageURL, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Add the new imageURL to the data item
                updatedDataItem["imageURL"] = imageURL
                
                // Update Firestore with the updated data item
                self.updateFirestoreWithDataAndLocation(currentUserID, updatedDataItem, manuallyPickedLocation: manuallyPickedLocation, completion)
            }
        } else {
            // No new image provided, directly update Firestore
            updateFirestoreWithDataAndLocation(currentUserID, updatedDataItem, manuallyPickedLocation: manuallyPickedLocation, completion)
        }
    }
    
    func deleteData(dataItem: DataModel, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppDomain", code: 401, userInfo: nil))
            return
        }

        let db = Firestore.firestore()
        let collection = db.collection("users")
        let document = collection.document(currentUserID)

        // Fetch the document to get the current array of data
        document.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }

            guard let document = document, document.exists else {
                // Handle the case when the document doesn't exist
                let documentNotExistError = NSError(domain: "YourAppDomain", code: 404, userInfo: nil)
                completion(documentNotExistError)
                return
            }

            // Get the current data array
            var dataArray = document.get("data") as? [[String: Any]] ?? []

            // Find the index of the data item with the specified ID
            if let indexToRemove = dataArray.firstIndex(where: { $0["id"] as? String == dataItem.id }) {
                // Remove the entry at the found index
                let imagetoDelete = dataArray[indexToRemove]["imageURL"] as? String
                self.deleteImageFromStorage(imageURL: imagetoDelete ?? "", currentUserID: currentUserID)
                dataArray.remove(at: indexToRemove)

                // Update Firestore with the modified array
                db.collection("users").document(currentUserID).updateData(["data": dataArray]) { error in
                    completion(error)
                }
            } else {
                // Handle the case when the ID is not found
                let idNotFoundError = NSError(domain: "YourAppDomain", code: 404, userInfo: nil)
                completion(idNotFoundError)
            }
        }
    }
    
    func getFullNameForCurrentUser(completion: @escaping () -> Void) {
            if let userId = Auth.auth().currentUser?.uid {
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(userId)

                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // Access the 'fullname' property directly
                        if let fullName = document.data()?["fullname"] as? String {
                            let words = fullName.components(separatedBy: " ")
                            let firstName = words.first
                            DispatchQueue.main.async {
                                self.fullName = firstName
                                
                                completion()
                            }
                            
                        } else {
                            print("Fullname not found in document data")
                        }
                    } else {
                        print("Document does not exist")
                    }
                }
            } else {
                print("No current user")
            }
        }
    
    
    func getAllDecoratedDates() -> Set<DateComponents> {
        return Set(self.data.compactMap { entry in
            guard let date = entry.timestamp?.dateValue() else { return nil }
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            return DateComponents(year: components.year, month: components.month, day: components.day)
        })
    }
}
