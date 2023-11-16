//
//  ContentView.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-11.
//


import SwiftUI
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack{
                Text("Welcome to Spotted!")
                    .font(.title)
                    .padding()
                HStack{
                    
                    Spacer()

                    NavigationLink(destination: LogInView()) {
                        Text("Log In")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }

                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(20)
                    }

                    Spacer()
                } //HStack
                NavigationLink(destination: MapView()) {
                    Text("View Map")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(20)
                }
            } //VStack            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
