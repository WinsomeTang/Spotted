//
//  LandmarkDetailsView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-22.
//

import SwiftUI
import MapKit

struct LandmarkDetailsView: View {
    var landmark: Landmark
    
    var body: some View {
        VStack {
            Text("Details for \(landmark.name)")
                .font(.title)
            
            Text("Additional information goes here.")
            

            Spacer()
        }
        .padding()
    }
}

struct LandmarkDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkDetailsView(landmark: Landmark())
    }
}
