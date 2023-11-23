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
    @StateObject private var detailsModel = LandmarkDetailsModel()

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
            Text("Phone: \(detailsModel.mapItem?.phoneNumber ?? "N/A")")
                .foregroundColor(.secondary)
                .padding(.bottom, 4)

            Text("Website: \(detailsModel.mapItem?.url?.absoluteString ?? "N/A")")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .onAppear {
            // Call the function to fetch additional information
            detailsModel.fetchMapItem(for: landmark)
        }
    }
}
