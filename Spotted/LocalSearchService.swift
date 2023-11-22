//
//  LocalSearchService.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-22.
//

import Foundation
import MapKit
import Combine

extension Notification.Name {
    static let userLocationUpdated = Notification.Name("userLocationUpdated")
}

class LocalSearchService: ObservableObject {
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    let locationManager = LocationManager()
    var cancellables = Set<AnyCancellable>()
    @Published var landmarks: [Landmark] = []
    @Published var landmark: Landmark?
    @Published private var isPresentedLocal: Bool = false
    
    var isPresented: Bool {
        get { isPresentedLocal }
        set {
            isPresentedLocal = newValue
            NotificationCenter.default.post(name: .userLocationUpdated, object: isPresentedLocal)
        }
    }

    
    init() {
        locationManager.userLocationCallback = { [weak self] location in
            self?.updateAnnotations(with: location)
        }
        
        NotificationCenter.default.publisher(for: .userLocationUpdated)
            .sink { [weak self] _ in
                self?.updateAnnotations(with: self?.locationManager.userLocationLocal)
            }
            .store(in: &cancellables)
        
        // Hardcoded search strings
        let searchStrings = ["pet store", "pet park", "pet hospital"]
        
        // Perform searches for each hardcoded string
        searchStrings.forEach { searchString in
            search(query: searchString)
        }
        
        // Initial search
        updateAnnotations(with: locationManager.userLocationLocal)
    }
    
    private func updateAnnotations(with location: CLLocationCoordinate2D?) {
        guard let userLocation = location else {
            return
        }
        
        region.center = userLocation
        
        // Clear existing landmarks
        landmarks.removeAll()
        
        // Hardcoded search strings
        let searchStrings = ["pet store", "pet park", "pet hospital"]
        
        // Perform searches for each hardcoded string
        searchStrings.forEach { searchString in
            search(query: searchString)
        }
    }
    
    // Updated search method to use hardcoded search strings
    private func search(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = locationManager.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    let mapItems = response.mapItems
                    self.landmarks.append(contentsOf: mapItems.map {
                        Landmark(placemark: $0.placemark)
                    })
                }
            }
        }
    }
}
