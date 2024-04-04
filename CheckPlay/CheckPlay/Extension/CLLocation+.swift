//
//  CLLocation+.swift
//  CheckPlay
//
//  Created by sole on 1/16/24.
//

import CoreLocation

extension CLLocation {
    func distance(to: CLLocationCoordinate2D) -> Int {
        return Int(self.distance(from: CLLocation(latitude: to.latitude,
                                                  longitude: to.longitude)))
    }
}
