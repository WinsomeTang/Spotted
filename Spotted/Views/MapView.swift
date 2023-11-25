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
                // Callback function to be triggered when the landmark is tapped
                printURL(for: landmark)
            }
        }
    }
}

struct MarkerImage: View {
    var landmark: Landmark

    var body: some View {
        let markerImage: Image

        switch landmark.searchQuery?.lowercased() {
        case "pet park":
            markerImage = Image(uiImage: UIImage(named: "pet-park-marker") ?? UIImage(systemName: "tree.fill")!)
        case "pet clinic":
            markerImage = Image(uiImage: UIImage(named: "pet-clinic-marker") ?? UIImage(systemName: "cross.fill")!)
        case "pet emergency 24 hours":
            markerImage = Image(uiImage: UIImage(named: "pet-emergency-marker") ?? UIImage(systemName: "cross.fill")!)
        case "pet store":
            markerImage = Image(uiImage: UIImage(named: "pet-store-marker") ?? UIImage(systemName: "storefront.fill")!)
        default:
            markerImage = Image(systemName: "heart.fill")
        }

        return markerImage
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30) // Adjust the size as needed
    }
}

// Function to print URL with dynamic query based on the tapped landmark
func printURL(for landmark: Landmark) {
    // Constructing the query with the name and address
    let query = "\(landmark.name) \(landmark.placemark?.title ?? "")"
    
    // Constructing the URL for the first request
    let firstURLString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=AIzaSyDxULNK8934DpI1H587uIwy3PhK8mDszv8"
    guard let firstURL = URL(string: firstURLString) else {
        print("Invalid URL for the first request.")
        return
    }

    // Using URLSession for asynchronous network request
    let task = URLSession.shared.dataTask(with: firstURL) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error)")
            return
        }

        guard let data = data else {
            print("No data received.")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let results = json?["results"] as? [[String: Any]], let firstResult = results.first, let placeID = firstResult["place_id"] as? String {
                // Use the placeID to construct the URL for the second request
                let secondURLString = "https://maps.googleapis.com/maps/api/place/details/json?fields=name%2Copening_hours%2Cformatted_address%2Cformatted_phone_number%2Cwebsite%2Curl%2Cphoto&place_id=\(placeID)&key=AIzaSyDxULNK8934DpI1H587uIwy3PhK8mDszv8"
                guard let secondURL = URL(string: secondURLString) else {
                    print("Invalid URL for the second request.")
                    return
                }

                // Perform the second request and print the JSON response
                let secondData = try Data(contentsOf: secondURL)
                let secondJSON = try JSONSerialization.jsonObject(with: secondData, options: [])
                print(secondJSON)
            } else {
                print("Could not extract place_id from the first JSON response.")
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    task.resume()
}



struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
