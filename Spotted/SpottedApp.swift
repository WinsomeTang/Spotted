//
//  SpottedApp.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-11.
//
import SwiftUI
import FirebaseCore
import GooglePlaces

@main
struct SpottedApp: App {
    init() {
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyDxULNK8934DpI1H587uIwy3PhK8mDszv8")
        print("Configured Firebase and Google Places! IT WORKS")
    }

    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environmentObject(LocalSearchService())
                .environmentObject(authViewModel)
        }
    }
}
