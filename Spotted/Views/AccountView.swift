//
//  AccountView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
// AccountView.swift

import SwiftUI
struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingLogoutAlert = false
    @State private var isShowingContentView = false
    @State private var isEditing = false
    @State private var updatedUsername = ""
    @State private var updatedEmail = ""

    var body: some View {
        NavigationView {
            VStack {
                if let currentUser = authViewModel.currentUser {
                    Text("Welcome, \(isEditing ? updatedUsername : currentUser.username)!")
                    Text("\(isEditing ? updatedEmail : currentUser.email)")

                    if !currentUser.pets.isEmpty {
                        Text("Your Pets:")
                            .font(.headline)

                        ForEach(currentUser.pets) { pet in
                            Text("\(pet.petName) - \(pet.petType.rawValue)")
                                .padding(.leading)
                        }
                    } else {
                        Text("No pets found.")
                            .foregroundColor(.gray)
                    }

                    if isEditing {
                        TextField("Username", text: $updatedUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        TextField("Email", text: $updatedEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }

                    Button(action: {
                        if isEditing {
                            // Save the edited information
                            authViewModel.updateUserInformation(username: updatedUsername, email: updatedEmail) { result in
                                switch result {
                                case .success:
                                    // Handle success
                                    print("User information updated successfully.")
                                case .failure(let error):
                                    // Handle failure
                                    print("Error updating user information: \(error.localizedDescription)")
                                }
                            }
                        }

                        // Toggle the editing mode
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Save Changes" : "Edit")
                            .foregroundColor(.white)
                            .padding()
                            .background(isEditing ? Color.green : Color.blue)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Show confirmation alert before logging out
                        isShowingLogoutAlert.toggle()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $isShowingLogoutAlert) {
                        Alert(
                            title: Text("Log Out"),
                            message: Text("Are you sure you want to log out?"),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text("Log Out")) {
                                // Log out action
                                authViewModel.logout()
                                isShowingContentView = true
                            }
                        )
                    }
                } else {
                    Text("Loading user information...")
                }
            }
            .padding()
            .onAppear {
                // Add console statement to check if user information is passed
                print("Checking currentUser in AccountView: \(authViewModel.currentUser)")
            }
            .fullScreenCover(isPresented: $isShowingContentView) {
                ContentView()
            }
        }
    }
}
