//
//  AuthViewModel.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-22.
//

import Foundation
import Firebase
import Combine
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var currentUser: PetOwner?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        // Load user data from UserDefaults when initializing the view model
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(PetOwner.self, from: userData) {
            self.currentUser = decodedUser
        }
    }
    func signUp(username: String, email: String, password: String, pets: [Pet], completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            } else {
                // User successfully signed up, now fetch user information and store it in the currentUser
                print("User signed up successfully:")
                print("Username: \(username)\nEmail: \(email)\nPassword: \(password)\nPets: \(pets)")
                self.storeUserInformation(username: username, email: email, password: password, pets: pets)
                self.fetchUserInformation(email: email) { result in
                    switch result {
                    case .success:
                        print("User information fetched successfully after sign up.")
                        completion(.success(()))
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        print("Error fetching user information after sign up: \(error)")
                        completion(.failure(error))
                    }
                }
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
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            currentUser = nil
            print("User logged out successfully.")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func updateUserInformation(username: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var currentUser = currentUser else {
            completion(.failure(NSError(domain: "AccountViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current user not found"])))
            return
        }

        guard let userId = currentUser.id else {
            completion(.failure(NSError(domain: "AccountViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])))
            return
        }

        let updatedUser = PetOwner(
            id : userId,
            username: username,
            email: email,
            password: currentUser.password,
            pets: currentUser.pets
        )

        let db = Firestore.firestore()
        do {
            try db.collection("PetOwners").document(userId).setData(from: updatedUser)

            // Update the currentUser properties
            currentUser.username = username
            currentUser.email = email

            // Update the published currentUser property
            self.currentUser = currentUser

            // Save user data to UserDefaults for persistence
            if let encodedUser = try? JSONEncoder().encode(updatedUser) {
                UserDefaults.standard.set(encodedUser, forKey: "currentUser")
            }

            // Print the updated user information
            print("User information updated successfully:")
            print("User ID: \(userId)")
            print("Updated Username: \(username)")
            print("Updated Email: \(email)")
            // ... add other fields you want to log

            completion(.success(()))
        } catch {
            print("Error updating user information: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    
    deinit {
        // Remove any subscriptions to avoid memory leaks
        cancellables.forEach { $0.cancel() }
    }

} //AuthViewModel
