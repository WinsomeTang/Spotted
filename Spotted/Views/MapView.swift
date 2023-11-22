//
//  MapView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var localSearchService: LocalSearchService
    @State private var showDetails: [UUID: Bool] = [:]

    var body: some View {
        TabView {
            // Map Tab
            Map(coordinateRegion: $localSearchService.region, showsUserLocation: true, annotationItems: localSearchService.landmarks) { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(localSearchService.landmark == landmark ? .purple: .red)
                        .scaleEffect(localSearchService.landmark == landmark ? 2: 1)
                        .onTapGesture {
                            showDetails[landmark.id, default: false] = true
                        }
                        .sheet(isPresented: Binding(
                            get: { showDetails[landmark.id, default: false] },
                            set: { showDetails[landmark.id] = $0 }
                        )) {
                            LandmarkDetailsView(landmark: landmark)
                        }
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar
            .navigationBarBackButtonHidden(true) // Hide the back button
            .mapStyle(.hybrid)
            .mapControls {
                MapUserLocationButton()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            // Activity Tab
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "chart.bar")
                }

            // Account Tab
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
    }
}




struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
