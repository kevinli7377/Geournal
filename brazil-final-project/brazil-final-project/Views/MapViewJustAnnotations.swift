//created by Hezzy on 10/27

import SwiftUI
import MapKit

struct MapViewJustAnnotations: UIViewRepresentable {
    @Binding var annotations: [MKAnnotation]
    @Binding var region: MKCoordinateRegion
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewJustAnnotations
        
        init(_ parent: MapViewJustAnnotations) {
            self.parent = parent
        }
        
        // Implement mapView(_:viewFor:) and other delegate methods for annotations if needed
    }
    
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
