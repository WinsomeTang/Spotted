//
//  LandmarkDetailsView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-22.
//


// DECEMBER 11 @1:16PM:  WE SAY GOODBYE TO OUR FELLOW GOOGLEPLACES API DETAILED VIEW BECAUSE OF IOS 17 BEING A PAIN IN THE..
// GOODBYE 20 HOURS OF WORK, WE WILL MEET AGAIN. o7



//import SwiftUI
//import MapKit
//
//struct LandmarkDetailsView: View {
//    var landmark: Landmark
//    @StateObject private var detailsModel = LandmarkDetailsModel()
//    @State private var showingDirections = false
//    var onLandmarkTapped: (() -> Void)?
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(landmark.name)
//                .font(.title)
//                .padding(.bottom, 8)
//                .multilineTextAlignment(.center)
//
//            if let address = detailsModel.formattedAddress {
//                Text("Address: \(address)")
//                    .foregroundColor(.secondary)
//                    .padding(.bottom, 4)
//            }
//
//            if let phoneNumber = detailsModel.phoneNumber {
//                Button(action: {
//                    if let phoneURL = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
//                        UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
//                    }
//                }) {
//                    Text("Phone: \(phoneNumber)")
//                        .foregroundColor(.blue)
//                        .padding(.bottom, 4)
//                }
//            }
//
//            Text("Website:")
//                .foregroundColor(.secondary)
//
//            if let website = detailsModel.website {
//                Link(website, destination: URL(string: website)!)
//                    .foregroundColor(.blue)
//            }
//
//            Text("Opening Hours:")
//                .font(.headline)
//                .padding(.top, 8)
//
//            if let weekdayText = detailsModel.weekdayText, !weekdayText.isEmpty {
//                ForEach(weekdayText, id: \.self) { text in
//                    if text.lowercased().contains("open 24 hours") {
//                        Text(text)
//                            .foregroundColor(.secondary)
//                            .bold() // Highlight "Open 24 hours" text
//                    } else {
//                        Text(text)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            } else {
//                Text("Not available")
//                    .foregroundColor(.secondary)
//            }
//
//            Button(action: {
//                // Navigate to DirectionsView
//                showingDirections = true
//            }) {
//                Text("Directions")
//                    .foregroundColor(.blue)
//                    .padding(.top, 8)
//            }
////            .fullScreenCover(isPresented: $showingDirections) {
////                DirectionsView(destination: landmark)
////            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            detailsModel.fetchMapItem(for: landmark)
//            onLandmarkTapped?()
//        }
//    }
//}
