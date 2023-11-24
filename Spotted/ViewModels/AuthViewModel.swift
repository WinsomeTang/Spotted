//
//  AuthViewModel.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-22.
//
// AuthViewModel.swift

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    func signUp(username: String, email: String, password: String, pets: [Pet]) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // User successfully signed up, now store user and pet info in Firestore
                self.storeUserInformation(username: username, email: email, password: password, pets: pets)
            }
        }
    }

    private func storeUserInformation(username: String, email: String, password: String, pets: [Pet]) {
        let userData = PetOwner(username: username, email: email, password: password, pets: pets)

        // Store user information in Firestore
        let db = Firestore.firestore()
        do {
            _ = try db.collection("PetOwners").addDocument(from: userData)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // Implement sign-in logic
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }

            if let error = error {
                strongSelf.errorMessage = error.localizedDescription
                print("Error: \(strongSelf.errorMessage)")
                completion(.failure(error))
            } else {
                // User successfully logged in
                strongSelf.isLoggedIn = true
                print("User is logged in")
                print("User \(email) is logged in with \(password)")
                completion(.success(()))
            }
        }
    }

}
