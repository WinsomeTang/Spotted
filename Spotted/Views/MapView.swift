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
    
    var body: some View {
        TabView {
            // Map Tab
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
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
