//
//  LocationManager.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import CoreLocation
import Combine

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

