//
//  LocationManager.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import MapKit

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    
    
    @Published var userLocationLocal: CLLocationCoordinate2D? {
        didSet {
            userLocationCallback?(userLocationLocal)
            
            // Use DispatchQueue.main.async to avoid publishing changes from within view updates
            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: .userLocationUpdated, object: self.userLocationLocal)
            }
        }
    }
    
    private var isUpdatingLocation = false
    
    var userLocationCallback: ((CLLocationCoordinate2D?) -> Void)?

    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
        locationManager.startUpdatingLocation()
        
//        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == .authorizedAlways) {
        
        // Check if the location manager has a location before assigning to currentLocation
        if let location = locationManager.location {
            currentLocation = location
            let longitude = location.coordinate.longitude
            let latitude = location.coordinate.latitude
            // Now you can use longitude and latitude as needed
        }
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.startUpdatingLocation()
        }
    }


    // Function to update userLocation and post notification
//    private func updateUserLocation(_ newValue: CLLocationCoordinate2D?) {
//        isUpdatingLocation = true
//        userLocationLocal = newValue
//        region = MKCoordinateRegion(
//            center: userLocationLocal!,
//            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        )
//        isUpdatingLocation = false
//    }
    private func updateUserLocation(_ newValue: CLLocationCoordinate2D?) {
        isUpdatingLocation = true
        
        if let newValue = newValue {
            userLocationLocal = newValue
            region = MKCoordinateRegion(
                center: newValue,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else {
             userLocationLocal = CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020)
        }
        isUpdatingLocation = false
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locations.last.map {
            updateUserLocation($0.coordinate)
        }
    }
}
