//
//  MapViewModel.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .region(.init(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    func updatePosition(coordinate: CLLocationCoordinate2D) {
        position = .region(.init(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }
}

