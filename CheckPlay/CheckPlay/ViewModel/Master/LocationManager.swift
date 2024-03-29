//
//  LocationManager.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/04/22.
//

import SwiftUI
import MapKit
import CoreLocation


class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: - Properties
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    
    
    //MARK: User Location
    @Published var userLocation: CLLocation?
    
    //MARK: Final Location
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlacemark: CLPlacemark?
    
    @Published var address: String?
    
    
    override init() {
        super.init()
        //MARK: Setting Delegates
        manager.delegate = self
        mapView.delegate = self
        
        //MARK: Requesting Location Access
        manager.requestWhenInUseAuthorization()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        //Handle Error
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        self.userLocation = currentLocation
    }
    
    
    //MARK: Location Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestLocation()
        case .denied: handleLocationError()
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default: ()
        }
    }
    
    func handleLocationError() {
        //Handle Error
    }
    
    
    //MARK: Add Draggable Map Pin to MapView
    func addDraggablePin(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        DispatchQueue.main.async {
            self.pickedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        mapView.addAnnotation(annotation)
    }
    
    
    
    //MARK: Enable Dragging
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation,
                                            reuseIdentifier: "PIN")
        marker.isDraggable = true
        marker.canShowCallout = false
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else { return }
        DispatchQueue.main.async {
            self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        }
        
        
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    
    
    func updatePlacemark(location: CLLocation) {
        Task {
            do {
                guard let place = try await reverseLocationCoordinates(location: location) else { return }
                await MainActor.run(body: {
                    self.pickedPlacemark = place
                })
                
            } catch {
                //Handle Error
            }
        }
    }
    
    
    //Displaying new Location Data
    func reverseLocationCoordinates(location: CLLocation) async throws -> CLPlacemark? {
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        
        return place
    }
    
    
}


//MARK: MapView Live Selection
struct MapViewSelection: View {
    @StateObject var locationManager: LocationManager
    var coordinate: CLLocationCoordinate2D
    var body: some View {
        VStack {
            MapViewHelper(locationManager: locationManager,
                          coordinate: coordinate)
        }.navigationBarBackButtonHidden(true)
        
        .onDisappear{
            if locationManager.mapView.annotations.isEmpty { return }
            locationManager.pickedLocation = nil
            locationManager.pickedPlacemark = nil
            locationManager.mapView.removeAnnotation(locationManager.mapView.annotations.first!)
        }
    }
}



//MARK: UIKit MapView
struct MapViewHelper: UIViewRepresentable {
    @StateObject var locationManager: LocationManager
    var coordinate: CLLocationCoordinate2D
    func makeUIView(context: Context) -> MKMapView {
        locationManager.manager.requestWhenInUseAuthorization()
        locationManager.addDraggablePin(coordinate: coordinate)
        locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        locationManager.mapView.setRegion(region, animated: true)
        
        return locationManager.mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
    
    }
}
