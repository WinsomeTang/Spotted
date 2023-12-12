//
//  ContentView.swift
//  Spotted_Watch Watch App
//
//  Created by Winsome Tang on 2023-12-11.
//

import SwiftUI

struct ContentView: View {
    @StateObject var sharedModel = SharedModel()

    var body: some View {
        VStack {
            Text("Watch Content")

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
