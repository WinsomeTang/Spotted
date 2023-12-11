//
//  ActivityView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//


import SwiftUI
import MapKit

struct ExpressView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var nearestPetStore: MKMapItem?
    @State private var nearestPetPark: MKMapItem?
    @State private var nearestPetClinic: MKMapItem?
    @State private var nearestPetHospital: MKMapItem?

    var body: some View {
        VStack {
            if let petStore = nearestPetStore {
                Text("Nearest Pet Store: \(petStore.name ?? "")")
            }
            if let petPark = nearestPetPark {
                Text("Nearest Pet Park: \(petPark.name ?? "")")
            }
            if let petClinic = nearestPetClinic {
                Text("Nearest Pet Clinic: \(petClinic.name ?? "")")
            }
            if let petHospital = nearestPetHospital {
                Text("Nearest Pet Hospital: \(petHospital.name ?? "")")
            }

            Button("Get Directions") {
                // Implement logic to get directions to the selected location
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
        }
        .onAppear() {
            Task { await searchNearestPlaces() }
        }
    }

    func searchNearestPlaces() async {
        let searchStrings = ["pet store", "pet food", "animal store", "petsmart", "pet valu", "pet park", "pet clinic", "pet emergency 24 hours"]
        let location = locationManager.currentLocation.coordinate

        for searchString in searchStrings {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchString
            request.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

            do {
                let searchResults = try await MKLocalSearch(request: request).start()

                switch searchString {
                case "pet store", "pet food", "animal store", "petsmart", "pet valu":
                    nearestPetStore = searchResults.mapItems.first
                case "pet park":
                    nearestPetPark = searchResults.mapItems.first
                case "pet clinic":
                    nearestPetClinic = searchResults.mapItems.first
                case "pet emergency 24 hours":
                    nearestPetHospital = searchResults.mapItems.first
                default:
                    break
                }
            } catch {
                print("Error searching for \(searchString): \(error.localizedDescription)")
            }
        }
    }
}

struct ExpressView_Previews: PreviewProvider {
    static var previews: some View {
        ExpressView()
    }
}
