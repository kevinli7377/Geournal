//
//  BigMapView.swift
//  Geournal
//
//  Created by Aryana Mohammadi on 12/4/23.
//

import Foundation
import SwiftUI
import MapKit


struct BigMapView: View {
    @State var camera: MapCameraPosition = .automatic
    @ObservedObject var viewModel: DataViewModel
    
    var body: some View {
        Map(position: $camera) {
            
            ForEach(viewModel.data) { entry in
                let lat_coord = entry.location?.latitude ?? 200.0
                let lon_coord = entry.location?.longitude ?? 200.0
                
                
               
                
                if (!(lat_coord == 200.0 && lon_coord == 200.0)) {
                    
                    
                    let coord = CLLocationCoordinate2D(latitude: lat_coord, longitude: lon_coord)
                    Marker("", coordinate: coord)
                    
                }
                
            }
            
        }
        .padding(0.2)
        .cornerRadius(15)
        .shadow(radius: 5)
        .mapControls {
            MapCompass()
            MapPitchToggle()
        }
        
    }
    
    

    
}
