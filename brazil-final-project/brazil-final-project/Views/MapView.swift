//
//  MapView.swift
//  brazil-final-project
//
//  Created by Hezzy on 11/24/23.
//

import SwiftUI
import MapKit


struct MapView: UIViewRepresentable
{

    @ObservedObject var locationManager: LocationManager
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        
    }
    
    //binding so that it gets passed to MapView
    @Binding var annotations: [MKAnnotation]
    @Binding var region: MKCoordinateRegion
                            
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
                            
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        uiView.setRegion(region, animated: true)
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}
