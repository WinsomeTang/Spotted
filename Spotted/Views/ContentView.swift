//
//  ContentView.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-11.
//


import SwiftUI
struct ContentView: View {
    
    //
    @State private var isMapViewActive = false
    @State private var isLogInViewActive = false
    @State private var isSignUpViewActive = false
    
    var body: some View {
        VStack {
            Text("Welcome to Spotted!")
                .font(.title)
                .padding()

            HStack {
                Spacer()

                Button("Log In"){
                  isLogInViewActive = true
                }
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(20)
                .fullScreenCover(isPresented: $isLogInViewActive) {
                    LogInView()
                }

                Button("Sign Up"){
                  isSignUpViewActive = true
                }
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
                .fullScreenCover(isPresented: $isSignUpViewActive) {
                    SignUpView()
                }
                Spacer()
            }

            Button("View Map") {
                isMapViewActive = true
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(20)
            .fullScreenCover(isPresented: $isMapViewActive) {
                MapView()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
