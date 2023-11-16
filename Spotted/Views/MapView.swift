//
//  MapView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI
import MapKit

struct MapItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var viewModel = MapViewModel()

    var body: some View {
        TabView {
            // Map Tab
            Map(position: $viewModel.position) {
                Marker("My Location", coordinate: locationManager.location.coordinate ?? CLLocationCoordinate2D())
                // Add other map content here
            }
            .onAppear {
                viewModel.updatePosition(coordinate: locationManager.location.coordinate ?? CLLocationCoordinate2D())
            }
            .onReceive(locationManager.$location) { _ in
                viewModel.updatePosition(coordinate: locationManager.location.coordinate ?? CLLocationCoordinate2D())
            }
            .navigationBarHidden(true) // Hide the navigation bar
            .navigationBarBackButtonHidden(true) // Hide the back button
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
