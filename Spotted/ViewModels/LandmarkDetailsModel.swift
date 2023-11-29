//
//  LandmarkDetailsModel.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-23.
//

import Foundation
import MapKit

class LandmarkDetailsModel: ObservableObject {
    @Published var mapItem: MKMapItem?
    @Published var boundingRegion: MKCoordinateRegion?
    @Published var phoneNumber: String?
    @Published var formattedAddress: String?
    @Published var website: String?
    @Published var weekdayText: [String]?

    
    func fetchMapItem(for landmark: Landmark) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = landmark.searchQuery
        request.region = MKCoordinateRegion(center: landmark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let mapItem = response?.mapItems.first {
                DispatchQueue.main.async {
                    self.mapItem = mapItem
                    self.boundingRegion = MKCoordinateRegion(center: mapItem.placemark.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)

                    // Fetch additional details
                    self.fetchDetails(for: landmark) { _ in }
                }
            } else if let error = error {
                print("Error fetching map item: \(error.localizedDescription)")
            }
        }
    }

    func fetchDetails(for landmark: Landmark, completion: @escaping (Bool) -> Void) {
        // Constructing the query with the name and address
        let query = "\(landmark.name) \(landmark.placemark?.title ?? "")"
        
        // Constructing the URL for the first request
        let firstURLString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(query)&key=AIzaSyDxULNK8934DpI1H587uIwy3PhK8mDszv8"
        guard let firstURL = URL(string: firstURLString) else {
            print("Invalid URL for the first request.")
            return
        }
        
        // Using URLSession for asynchronous network request
        URLSession.shared.dataTask(with: firstURL) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let results = json?["results"] as? [[String: Any]], let firstResult = results.first, let placeID = firstResult["place_id"] as? String {
                    // Use the placeID to construct the URL for the second request
                    let secondURLString = "https://maps.googleapis.com/maps/api/place/details/json?fields=name%2Copening_hours%2Cformatted_address%2Cformatted_phone_number%2Cwebsite%2Curl%2Cphoto&place_id=\(placeID)&key=AIzaSyDxULNK8934DpI1H587uIwy3PhK8mDszv8"
                    guard let secondURL = URL(string: secondURLString) else {
                        print("Invalid URL for the second request.")
                        return
                    }

                    // Perform the second request and print the JSON response
                    URLSession.shared.dataTask(with: secondURL) { secondData, _, secondError in
                        if let secondError = secondError {
                            print("Error fetching details: \(secondError)")
                            completion(false)
                            return
                        }

                        guard let secondData = secondData else {
                            print("No data received for details.")
                            completion(false)
                            return
                        }

                        do {
                            let decoder = JSONDecoder()
                            let detailsResponse = try decoder.decode(DetailsResponse.self, from: secondData)

                            // Update properties with fetched details
                            DispatchQueue.main.async {
                                self.weekdayText = detailsResponse.result.opening_hours?.weekday_text
                                self.phoneNumber = detailsResponse.result.formatted_phone_number
                                self.formattedAddress = detailsResponse.result.formatted_address
                                self.website = detailsResponse.result.website
                                
                                let isOpen24Hours = detailsResponse.result.opening_hours?.open_now ?? false
                                    completion(isOpen24Hours)
                            }
                        } catch {
                            print("Error decoding details response: \(error)")
                            completion(false)
                        }
                    }.resume()
                } else {
                    print("Could not extract place_id from the first JSON response.")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }

    
    struct PlaceResult: Decodable {
        let formatted_address: String?
        let formatted_phone_number: String?
        let name: String?
        let opening_hours: OpeningHours?
        let url: String?
        let website: String?
    }
    
    struct OpeningHours: Decodable {
        let open_now: Bool
        let periods: [Period]
        let weekday_text: [String]?
    }
    
    struct Period: Decodable {
        let close: DayTime?
        let open: DayTime
    }
    
    struct DayTime: Decodable {
        let day: Int
        let time: String
    }
    
    
    struct DetailsResponse: Decodable {
        let result: PlaceResult
    }
}
