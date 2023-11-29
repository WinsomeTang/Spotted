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
    @State private var selectedLandmark: Landmark?

    var body: some View {
        TabView {
            // Map Tab
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: localSearchService.landmarks) { landmark in
                MapAnnotation(coordinate: landmark.coordinate) {
                    MarkerImage(landmark: landmark)
                        .onTapGesture {
                            selectedLandmark = landmark
                        }
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
//            .mapStyle(.hybrid)
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
        .sheet(item: $selectedLandmark) { landmark in
            LandmarkDetailsView(landmark: landmark) {
            }
        }
    }
}

struct MarkerImage: View {
    var landmark: Landmark

    var body: some View {
        let markerImage: Image

        switch (landmark.searchQuery?.lowercased(), landmark.isOpen24Hours) {
        case ("pet park", _):
            markerImage = Image(uiImage: UIImage(named: "pet-park-marker") ?? UIImage(systemName: "tree.fill")!)
        case ("pet clinic", _):
            markerImage = Image(uiImage: UIImage(named: "pet-clinic-marker") ?? UIImage(systemName: "cross.fill")!)
        case ("pet emergency 24 hours", true):
            markerImage = Image(uiImage: UIImage(named: "pet-emergency-marker") ?? UIImage(systemName: "cross.fill")!)
        case ("pet emergency 24 hours", false):
            markerImage = Image(uiImage: UIImage(named: "pet-clinic-marker") ?? UIImage(systemName: "cross.fill")!)
        case ("pet store", _):
            markerImage = Image(uiImage: UIImage(named: "pet-store-marker") ?? UIImage(systemName: "storefront.fill")!)
        default:
            markerImage = Image(systemName: "heart.fill")
        }
        
        return markerImage
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
    }
}



struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
