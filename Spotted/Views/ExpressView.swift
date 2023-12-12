//
//  ExpressView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI
import MapKit

struct ExpressView: View {
    @ObservedObject var locationManager = LocationManager()
    @StateObject var sharedModel = SharedModel()
    @Binding var showMapView: Bool

    var body: some View {
        VStack {
            if let petStore = sharedModel.nearestPetStore {
                PetPlaceRow(name: "Nearest Pet Store:", place: petStore, color: .blue)
            }
            if let petPark = sharedModel.nearestPetPark {
                PetPlaceRow(name: "Nearest Pet Park:", place: petPark, color: .green)
            }
            if let petClinic = sharedModel.nearestPetClinic {
                PetPlaceRow(name: "Nearest Pet Clinic:", place: petClinic, color: .orange)
            }
            if let petHospital = sharedModel.nearestPetHospital {
                PetPlaceRow(name: "Nearest Pet Hospital:", place: petHospital, color: .red)
            }

            Button("Find Closest in Map") {
                showMapView = true
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
                    sharedModel.nearestPetStore = searchResults.mapItems.first
                case "pet park":
                    sharedModel.nearestPetPark = searchResults.mapItems.first
                case "pet clinic":
                    sharedModel.nearestPetClinic = searchResults.mapItems.first
                case "pet emergency 24 hours":
                    sharedModel.nearestPetHospital = searchResults.mapItems.first
                default:
                    break
                }
            } catch {
                print("Error searching for \(searchString): \(error.localizedDescription)")
            }
        }
    }
}


struct PetPlaceRow: View {
    var name: String
    var place: MKMapItem
    var color: Color

    var body: some View {
        HStack {
            Text("\(name) \(place.name ?? "")")
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "location.fill")
                .foregroundColor(color)
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

//struct ExpressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpressView()
//    }
//}
