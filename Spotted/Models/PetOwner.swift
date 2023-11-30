//
//  PetOwner.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PetOwner: Identifiable, Encodable {
    @DocumentID var id: String?
    var username: String
    var email: String
    var password: String
    var pets: [Pet]
}

struct Pet: Identifiable, Encodable {
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

    var id: String?
    var petName: String
    var petType: PetType
}
