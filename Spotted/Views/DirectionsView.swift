//
//  DirectionsView.swift
//  Spotted
//
//  Created by Michael Werbowy on 2023-11-29.
//

import SwiftUI
import MapKit
import CoreLocation

// Conform CLLocationCoordinate2D and MKCoordinateSpan to Equatable
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        return lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

struct DirectionsMapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var span: MKCoordinateSpan
    var landmarks: [Landmark]

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: DirectionsMapView

        init(parent: DirectionsMapView) {
            self.parent = parent
        }

        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            // Set the initial region when the map is fully loaded
            if let userLocation = mapView.userLocation.location?.coordinate,
               let destination = parent.landmarks.first?.coordinate {
                let midpoint = CLLocationCoordinate2D(
                    latitude: (userLocation.latitude + destination.latitude) / 2,
                    longitude: (userLocation.longitude + destination.longitude) / 2
                )

                parent.centerCoordinate = midpoint
                print("Initial Center Coordinate: \(parent.centerCoordinate)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the map annotations or other configurations if needed
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(landmarks.map { landmark in
            let annotation = MKPointAnnotation()
            annotation.coordinate = landmark.coordinate
            return annotation
        })

        // Update the region based on the bindings
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        uiView.setRegion(region, animated: true)
    }
}

struct DirectionsView: View {
    var destination: Landmark
    @State private var route: MKRoute?
    @State private var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    @Environment(\.presentationMode) var presentationMode
    @State private var locationManager = CLLocationManager()

    var body: some View {
        VStack {
            Text("Directions to \(destination.name)")
                .font(.headline)
                .padding()

            DirectionsMapView(centerCoordinate: $centerCoordinate, span: $span, landmarks: [destination])
                .overlay(
                    MapPolyline(polyline: route?.polyline ?? MKPolyline())
                        .stroke(Color.blue, lineWidth: 5)
                )
                .onAppear {
                    getDirections()
                }

            HStack {
                if let route = route {
                    Text("ETA: \(formattedETA(route.expectedTravelTime))")
                    Spacer()
                    Text("Distance: \(formattedDistance(route.distance))")
                    Spacer()
                }
                Button("Dismiss") {
                    // Dismiss the DirectionsView
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func getDirections() {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first, error == nil else {
                print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.route = route
        }
    }

    private func formattedETA(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: timeInterval) ?? "N/A"
    }

    private func formattedDistance(_ distance: CLLocationDistance) -> String {
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .short
        return formatter.string(from: measurement)
    }
}

struct DirectionsView_Previews: PreviewProvider {
    static var previews: some View {
        // Replace with appropriate preview code
        DirectionsView(destination: Landmark())
    }
}

struct MapPolyline: Shape {
    var polyline: MKPolyline

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let points = polyline.points()

        guard polyline.pointCount > 0 else {
            return path
        }

        let firstPoint = points[0].coordinate
        path.move(to: CGPoint(x: firstPoint.latitude, y: firstPoint.longitude))

        for index in 1..<polyline.pointCount {
            let point = points[index].coordinate
            path.addLine(to: CGPoint(x: point.latitude, y: point.longitude))
        }

        return path
            .strokedPath(StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
    }
}
