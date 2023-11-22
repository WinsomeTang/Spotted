//
//  Landmark.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-22.
//

import MapKit

struct Landmark: Identifiable, Hashable {
    
    let placemark: MKPlacemark?
    
    let id = UUID()
    
    let searchQuery: String?

    
    init(placemark: MKPlacemark? = nil, searchQuery: String? = nil) {
        self.placemark = placemark
        self.searchQuery = searchQuery
    }
    
    var name: String {
        self.placemark?.name ?? ""
    }
    
    var title: String {
        self.placemark?.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.placemark?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}