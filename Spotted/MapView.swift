//
//  MapView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI
import MapKit
import CoreLocation

class Location: ObservableObject {
    @Published var coordinate: CLLocationCoordinate2D?

    init(coordinate: CLLocationCoordinate2D?) {
        self.coordinate = coordinate
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location = Location(coordinate: nil)

    private var locationManager = CLLocationManager()

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            location.coordinate = coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

struct MapItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .region(.init(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))

    var body: some View {
        Map(position: $position) {
            Marker("My Location", coordinate: locationManager.location.coordinate ?? CLLocationCoordinate2D())
            // Add other map content as needed
        }
        .onAppear {
            // Perform any setup tasks if needed
            updatePosition()
        }
        .onReceive(locationManager.$location) { _ in
            updatePosition()
        }
        .navigationBarTitle("Map")
    }

    private func updatePosition() {
        if let coordinate = locationManager.location.coordinate {
            position = .region(.init(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
