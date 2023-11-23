//
//  LogInView.swift
//  Spotted
//
//  Created by Winsome Tang on 2023-11-15.
//

import SwiftUI

struct LogInView: View {
    @State private var username = ""
    @State private var password = ""
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel : AuthViewModel

    var body: some View {
        VStack{
            Text("Welcome Back")
          
            TextField("Username", text: self.$username)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            SecureField("Password", text: self.$password)
                .font(.title2)
                .keyboardType(.alphabet)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button{
                print("Log User in...")
                
            } label: {
                Text("Sign In")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
            }
            .padding()
            .background(Color(.systemBlue))
            .cornerRadius(10)
            
            
        }
       
    }
}

#Preview {
    LogInView()
}
