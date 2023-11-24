//
//  SignUpView.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-15.
import SwiftUI
import Firebase

struct SignUpView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var petName = ""
    @State private var petType: Pet.PetType = .dog
    @State private var pets: [Pet] = []

    @State private var showPetEntry = false
    @State private var navigateToMapView = false

    var body: some View {
        NavigationView {
            VStack {
                if !showPetEntry {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }

                if showPetEntry {
                    ForEach(pets.indices, id: \.self) { index in
                        VStack {
                            TextField("Pet Name", text: $pets[index].petName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                            Picker("Pet Type", selection: $pets[index].petType) {
                                ForEach(Pet.PetType.allCases, id: \.self) { type in
                                    Text(type.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.wheel)
                            .padding()
                        }
                    }

                    Button("Add Pet") {
                        pets.append(Pet(petName: petName, petType: petType))
                    }
                    .padding()
                    
                    NavigationLink(destination: MapView(), isActive: $navigateToMapView) {
                        Button("Get Started!") {
                            navigateToMapView = true
                            authViewModel.signUp(username: username, email: email, password: password, pets: pets)
                        }
                        .padding()
                    }
                    .padding()
                } else {
                    Button("Next") {
                        showPetEntry = true
                    }
                    .padding()
                }

                Button("Back") {
                    showPetEntry = false
                }
                .padding()

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }//error message
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
