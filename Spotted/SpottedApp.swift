//
//  SpottedApp.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-11.
//
import SwiftUI
import FirebaseCore

@main
struct SpottedApp: App {
    init(){
        FirebaseApp.configure()
        print("Configured Firebase! IT WORKSs")
    }
    
  var body: some Scene {
    WindowGroup {
        ContentView()
    
//        TO TEST MAPVIEW
//        MapView()
//            .navigationBarTitle("Map")
    }
  }
}
