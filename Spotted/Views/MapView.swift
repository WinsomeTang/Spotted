//
//  MapView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-15.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
//    @EnvironmentObject var localSearchService: LocalSearchService
//    @State private var selectedLandmark: Landmark?
    
    var userLatitude: String{
        return "\(locationManager.currentLocation.coordinate.latitude)"
    }
    var userLongitude: String {
        return "\(locationManager.currentLocation.coordinate.longitude)"
    }
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var results = [MKMapItem]()
    @State private var storeResults = [MKMapItem]()
    @State private var parkResults = [MKMapItem]()
    @State private var clinicResults = [MKMapItem]()
    @State private var hospitalResults = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    //default cam position
    @State var camera: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
            UserAnnotation()

            ForEach(storeResults, id: \.self) { item in
                if routeDisplaying, item == routeDestination {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "storefront.fill" ,coordinate: placemark.coordinate)
                        .tint(.blue)
                } else if !routeDisplaying {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "storefront.fill" ,coordinate: placemark.coordinate)
                        .tint(.blue)
                }
            }
            ForEach(parkResults, id: \.self) { item in
                if routeDisplaying, item == routeDestination {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "tree.fill" ,coordinate: placemark.coordinate)
                        .tint(.green)
                } else if !routeDisplaying {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "tree.fill" ,coordinate: placemark.coordinate)
                        .tint(.green)
                }
            }
            ForEach(clinicResults, id: \.self) { item in
                if routeDisplaying, item == routeDestination {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "building.fill" ,coordinate: placemark.coordinate)
                        .tint(.orange)
                } else if !routeDisplaying {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "building.fill" ,coordinate: placemark.coordinate)
                        .tint(.orange)
                }
            }
            ForEach(hospitalResults, id: \.self) { item in
                if routeDisplaying, item == routeDestination {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "cross.fill" ,coordinate: placemark.coordinate)
                        .tint(.red)
                } else if !routeDisplaying {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", systemImage: "cross.fill" ,coordinate: placemark.coordinate)
                        .tint(.red)
                }
            }


            if let route = route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        .onAppear() {
            Task { await searchPlaces() }
        }
        .onChange(of: getDirections) { oldValue, newValue in
            if newValue {
                fetchRoute()
            }
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            showDetails = newValue != nil
        }
        .sheet(isPresented: $showDetails) {
            LocationDetailsView(mapSelection: $mapSelection,
                                show: $showDetails,
                                getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
    }
}

extension MapView{
    func searchPlaces() async {
        let stores = ["pet store", "pet food", "animal store", "petsmart", "pet valu"]
        let parks = ["pet park"]
        let clinics = ["pet clinic"]
        let hospitals = ["pet emergency 24 hours"]

        for searchString in stores {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchString

            do {
                let storeResults = try await MKLocalSearch(request: request).start()
                self.storeResults.append(contentsOf: storeResults.mapItems)
            } catch {
                print("Error searching for \(searchString): \(error.localizedDescription)")
            }
        }
        for searchString in parks {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchString

            do {
                let parkResults = try await MKLocalSearch(request: request).start()
                self.parkResults.append(contentsOf: parkResults.mapItems)
            } catch {
                print("Error searching for \(searchString): \(error.localizedDescription)")
            }
        }
        for searchString in clinics {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchString

            do {
                let clinicResults = try await MKLocalSearch(request: request).start()
                self.clinicResults.append(contentsOf: clinicResults.mapItems)
            } catch {
                print("Error searching for \(searchString): \(error.localizedDescription)")
            }
        }
        for searchString in hospitals {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchString

            do {
                let hospitalResults = try await MKLocalSearch(request: request).start()
                self.hospitalResults.append(contentsOf: hospitalResults.mapItems)
            } catch {
                print("Error searching for \(searchString): \(error.localizedDescription)")
            }
        }
        
    }
    
    func fetchRoute(){
        if let mapSelection{
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: locationManager.currentLocation.coordinate))
            request.destination = mapSelection
            
            Task{
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy){
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying{
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
