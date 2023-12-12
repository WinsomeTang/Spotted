//
//  PetOwner.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PetOwner: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userID = UUID()
    var email: String
    var password: String
    var pets: [Pet]
}

struct Pet: Identifiable, Codable {
    enum PetType: String, Codable, CaseIterable {
        case dog
        case cat
        case hamster
        case rabbit
        case bird
        case fish
        case horse
        case reptile
        // Add more pet types as needed
    }

    var id = UUID()
    var petName: String
    var petType: PetType
}
