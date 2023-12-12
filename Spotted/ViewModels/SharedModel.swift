//
//  SharedModel.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-12-11.
//

import Foundation
import MapKit
import SwiftUI
class SharedModel: ObservableObject {
    @Published var nearestPetStore: MKMapItem?
    @Published var nearestPetPark: MKMapItem?
    @Published var nearestPetClinic: MKMapItem?
    @Published var nearestPetHospital: MKMapItem?
}
