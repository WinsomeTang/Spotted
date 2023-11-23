//
//  LandmarkDetailsModel.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-23.
//

import Foundation
import MapKit

class LandmarkDetailsModel: ObservableObject {
    @Published var mapItem: MKMapItem?
    @Published var boundingRegion: MKCoordinateRegion?

    func fetchMapItem(for landmark: Landmark) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = landmark.searchQuery
        request.region = MKCoordinateRegion(center: landmark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let mapItem = response?.mapItems.first {
                DispatchQueue.main.async {
                    self.mapItem = mapItem
                    self.boundingRegion = MKCoordinateRegion(center: mapItem.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                }
            } else if let error = error {
                print("Error fetching map item: \(error.localizedDescription)")
            }
        }
    }
}
