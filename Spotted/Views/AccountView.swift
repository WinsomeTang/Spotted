//
//  AccountView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
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
            } else {
                Text("Loading user information...")
            }
        }
        .padding()
        .onAppear {
            // Add console statement to check if user information is passed
            print("Checking currentUser in AccountView: \(authViewModel.currentUser)")
        }
    }
}


//#Preview {
//    AccountView(currentUser: )
//}
