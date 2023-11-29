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
    @Published private var detailsModel: LandmarkDetailsModel

    
    var isPresented: Bool {
        get { isPresentedLocal }
        set {
            isPresentedLocal = newValue
            NotificationCenter.default.post(name: .userLocationUpdated, object: isPresentedLocal)
        }
    }
    
    
    init() {
        self.detailsModel = LandmarkDetailsModel()

        locationManager.userLocationCallback = { [weak self] location in
            self?.updateAnnotations(with: location)
        }
        
        NotificationCenter.default.publisher(for: .userLocationUpdated)
            .sink { [weak self] _ in
                self?.updateAnnotations(with: self?.locationManager.userLocationLocal)
            }
            .store(in: &cancellables)
        
        // Hardcoded search strings
        let searchStrings = ["pet store", "pet park", "pet clinic", "pet emergency 24 hours"]
        
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
        let searchStrings = ["pet store", "pet park", "pet clinic", "pet emergency 24 hours"]

        // Perform searches for each hardcoded string
        searchStrings.forEach { searchString in
            search(query: searchString)
        }
    }
    
    private func search(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = locationManager.region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    let mapItems = response.mapItems
                    for mapItem in mapItems {
                        let landmark = Landmark(placemark: mapItem.placemark, searchQuery: query)
                        let updatedLandmark = self.isOpen24Hours(for: landmark, detailsModel: self.detailsModel)
                    }
                }
            }
        }
    }

    private func isOpen24Hours(for landmark: Landmark, detailsModel: LandmarkDetailsModel) -> Landmark {
        var updatedLandmark = landmark // Creates a mutable copy
        detailsModel.fetchDetails(for: landmark) { isOpen24Hours in
            DispatchQueue.main.async {
                updatedLandmark.isOpen24Hours = isOpen24Hours
                self.landmarks.append(updatedLandmark)
            }
        }
        return updatedLandmark
    }
}



