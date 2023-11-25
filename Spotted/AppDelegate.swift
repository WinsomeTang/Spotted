//
//  AppDelegate.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-24.
//

import Foundation
import GooglePlaces

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize Google Places API
        GMSPlacesClient.provideAPIKey("AIzaSyDxULNK8934DpI1H587uIwy3PhK8mDszv8")

        return true
    }
}
