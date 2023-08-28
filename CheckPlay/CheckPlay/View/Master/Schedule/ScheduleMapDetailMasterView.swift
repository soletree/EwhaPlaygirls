//
//  ScheduleMapDetailView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/04/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct ScheduleMapDetailMasterView: View {
    var region: MKCoordinateRegion {
        .init(center: center,
                       latitudinalMeters: 300,
                       longitudinalMeters: 300)
    }
    @Binding var center: CLLocationCoordinate2D
    var places: [Place] {
        [Place(latitude: center.latitude,
               longitude: center.longitude)]
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(region), annotationItems: places) { place in
            MapPin(coordinate: place.coordinate, tint: .green)
        }
        
    }
}

struct Place: Identifiable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: self.latitude, longitude: self.longitude)
    }
}
