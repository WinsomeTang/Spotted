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
    @State private var isMapViewActive = false

    var body: some View {
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
                
                Button("Get Started!") {
                    authViewModel.signUp(username: username, email: email, password: password, pets: pets) { result in
                        switch result {
                        case .success:
                            isMapViewActive = true
                        case .failure(let error):
                            // Handle the error, if needed
                            print("Error signing up: \(error.localizedDescription)")
                        }
                    }
                }
                .padding()
            } else {
                Button("Next") {
                    if password.count < 6{
                        authViewModel.errorMessage = "Password must be at least 6 characters long:("
                    }else{
                        showPetEntry = true
                    }
                }
                .padding()
            }

            Button("Back") {
                showPetEntry = false
                presentationMode.wrappedValue.dismiss()
            }
            .padding()

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } //error message
        }
        .fullScreenCover(isPresented: $isMapViewActive) {
            MapView()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
