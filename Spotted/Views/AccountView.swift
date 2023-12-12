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

    var body: some View {
        NavigationView {
            VStack {
                if let currentUser = authViewModel.currentUser {
                    Text("Welcome, \(currentUser.username)!")
                    Text("\(currentUser.email)")

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
