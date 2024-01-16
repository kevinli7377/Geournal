//
//  LocationManager.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/11/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        startUpdatingLocation()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
       // startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
            locationManager.startUpdatingLocation()
        }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // getting loc every 40 meters
        if let lastLocation = lastLocation, newLocation.distance(from: lastLocation) >= 40 {
            currentLocation = newLocation
            self.lastLocation = newLocation
        } else {
            // If the user hasn't moved 40 meters, update lastLocation
            self.lastLocation = newLocation
        }
        currentLocation = newLocation
    }
}
