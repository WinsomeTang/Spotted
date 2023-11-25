//
//  LogInView.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-15.
//
import SwiftUI
import Firebase
import FirebaseFirestore

struct LogInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var isMapViewActive = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Welcome Back")
            
            TextField("Email", text: self.$email)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .padding()
            
            SecureField("Password", text: self.$password)
                .font(.title2)
                .keyboardType(.alphabet)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button {
                authViewModel.login(email: email, password: password) { result in
                    switch result {
                    case .success:
                        isMapViewActive = true
                    case .failure(let error):
                        showAlert = true
                        alertMessage = error.localizedDescription
                    }
                }
            } label: {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $isMapViewActive) {
                MapView()
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
