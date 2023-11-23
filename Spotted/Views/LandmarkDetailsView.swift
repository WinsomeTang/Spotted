//
//  LandmarkDetailsView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-22.
//

import SwiftUI
import MapKit

struct LandmarkDetailsView: View {
    var landmark: Landmark
    @State private var mapItem: MKMapItem?
    @State private var boundingRegion: MKCoordinateRegion?

    var body: some View {
        VStack(alignment: .leading) {
            Text(landmark.name)
                .font(.title)
                .padding(.bottom, 8)

            if let placemark = landmark.placemark {
                Text("Address: \(placemark.title ?? "")")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            Text("Latitude: \(landmark.coordinate.latitude)")
                .foregroundColor(.secondary)
            Text("Longitude: \(landmark.coordinate.longitude)")
                .foregroundColor(.secondary)

            // Add these sections for phone number and URL
            Text("Phone: \(mapItem?.phoneNumber ?? "N/A")")
                .foregroundColor(.secondary)
                .padding(.bottom, 4)

            Text("Website: \(mapItem?.url?.absoluteString ?? "N/A")")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .onAppear {
            // Call the function to fetch additional information
            fetchMapItem()
        }
    }

    // Function to fetch additional information for the landmark
    private func fetchMapItem() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = landmark.searchQuery
        request.region = MKCoordinateRegion(center: landmark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let search = MKLocalSearch(request: request)
        let currentView = self // Capture the current view's identity

        search.start { response, error in
            // Ensure that the view is still relevant when the completion block is executed
            guard currentView.mapItem == nil else { return }

            if let mapItem = response?.mapItems.first {
                // Update the UI on the main thread
                DispatchQueue.main.async {
                    currentView.mapItem = mapItem
                    currentView.boundingRegion = MKCoordinateRegion(center: mapItem.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                }
            } else if let error = error {
                print("Error fetching map item: \(error.localizedDescription)")
            }
        }
    }
}
