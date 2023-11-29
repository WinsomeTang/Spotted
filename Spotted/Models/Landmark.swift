//
//  Landmark.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-22.
//

import MapKit

struct Landmark: Identifiable, Hashable {
    var placemark: MKPlacemark?
    var id = UUID()
    var searchQuery: String?
    var isOpen24Hours: Bool
    
    var phoneNumber: String?
    var websiteURL: URL?

    init(placemark: MKPlacemark? = nil, searchQuery: String? = nil, isOpen24Hours: Bool = false) {
        self.placemark = placemark
        self.searchQuery = searchQuery
        self.isOpen24Hours = isOpen24Hours
    }

    var name: String {
        placemark?.name ?? ""
    }

    var title: String {
        placemark?.title ?? ""
    }

    var coordinate: CLLocationCoordinate2D {
        placemark?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    var formattedPhoneNumber: String {
        return phoneNumber ?? "N/A"
    }

    var formattedWebsiteURL: String {
        return websiteURL?.absoluteString ?? "N/A"
    }
}
