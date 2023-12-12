//
//  AuthViewModel.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-22.
//

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var currentUser: PetOwner?
    
    func signUp(username: String, email: String, password: String, pets: [Pet]) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // User successfully signed up, now store user and pet info in Firestore
                print("User signed up successfully:")
                print("Username: \(username)\nEmail: \(email)\nPassword: \(password)\nPets: \(pets)")
                self.storeUserInformation(username: username, email: email, password: password, pets: pets)
            }
        }
    }
    
    private func storeUserInformation(username: String, email: String, password: String, pets: [Pet]) {
        let userData = PetOwner(username: username, email: email, password: password, pets: pets)
        
        // Store user information in Firestore
        let db = Firestore.firestore()
        do {
            let documentReference = try db.collection("PetOwners").addDocument(from: userData)
            print("User information stored successfully with ID: \(documentReference.documentID)")
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error storing user information: \(error)")
        }
    }
    
    func fetchUserInformation(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("PetOwners")
            .whereField("email", isEqualTo: email)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                } else {
                    if let document = snapshot?.documents.first {
                        let data = document.data()

                        if let username = data["username"] as? String,
                           let email = data["email"] as? String,
                           let password = data["password"] as? String,
                           let petsData = data["pets"] as? [Any] {
                               do {
                                   let pets = try petsData.map { try Firestore.Decoder().decode(Pet.self, from: $0) }
                                   let id = data["id"] as? String ?? UUID().uuidString
                                   let user = PetOwner(id: id, username: username, email: email, password: password, pets: pets)
                                   self.currentUser = user

                                   print("User information fetched successfully: \(user)")
                                   completion(.success(()))
                               } catch {
                                   self.errorMessage = error.localizedDescription
                                   print("Error decoding user information: \(error)")
                                   completion(.failure(error))
                               }
                        }
                    } else {
                        print("No documents found for the given email.")
                        completion(.failure(NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No documents found"])))
                    }
                }
            }
        }

        func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }

                if let error = error {
                    strongSelf.errorMessage = error.localizedDescription
                    print("Error: \(String(describing: strongSelf.errorMessage))")
                    completion(.failure(error))
                } else {
                    print("User is logged in")
                    print("User \(email) is logged in with \(password)")

                    strongSelf.fetchUserInformation(email: email) { result in
                        switch result {
                        case .success:
                            strongSelf.isLoggedIn = true
                            print("Login successful. Moving to MapView.")
                            completion(.success(()))
                        case .failure(let error):
                            strongSelf.errorMessage = error.localizedDescription
                            print("Error fetching user information after login: \(error)")
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
}

