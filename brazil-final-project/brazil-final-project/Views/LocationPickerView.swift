//
//  LocationPickerView.swift
//  Geournal
//
//  Created by Kevin Li on 12/3/23.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D
    var onLocationChange: (CLLocationCoordinate2D) -> Void

    @State private var mapCameraPosition: MapCameraPosition

    @Environment(\.dismiss) var dismiss

    init(selectedLocation: Binding<CLLocationCoordinate2D>, onLocationChange: @escaping (CLLocationCoordinate2D) -> Void) {
        self._selectedLocation = selectedLocation
        self.onLocationChange = onLocationChange

        let initialRegion = MKCoordinateRegion(center: selectedLocation.wrappedValue, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self._mapCameraPosition = State(initialValue: .region(initialRegion))
    }

    var body: some View {
        VStack {
            Map(initialPosition: mapCameraPosition)
                .onMapCameraChange(frequency: .continuous) { context in
                    mapCameraPosition = .region(context.region)
                }
                .overlay(
                    Circle()
                        .fill(Color.red)
                        .frame(width: 15, height: 15)
                        .offset(x: 0, y: -7.5) // Adjust the offset as needed
                )

            Button("Select This Location") {
                if let center = mapCameraPosition.region?.center {
                    onLocationChange(center)
                    dismiss()
                }
            }
            .padding()
            .background(Color("BrandColor"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            mapCameraPosition = .region(MKCoordinateRegion(center: selectedLocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
    }
}
