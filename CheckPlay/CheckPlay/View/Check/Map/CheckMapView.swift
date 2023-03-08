//
//  CheckMapView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import NMapsMap
import CoreLocation

struct CheckMapView: View {
    var circleCenter: CLLocationCoordinate2D = .init(latitude: 37.5666102, longitude: 126.9783881)
    var circleRadius: Double = 20
    var body: some View {
        NaverMapView(circleCenter: circleCenter, circleRadius: circleRadius)
    }
}


struct NaverMapView: UIViewRepresentable {
    let mapController = NaverMapViewController()
    var circleCenter: CLLocationCoordinate2D
    var circleRadius: Double
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()

        view.mapView.positionMode = .compass
        
        view.mapView.allowsZooming = true
        view.mapView.zoomLevel = 15
        view.mapView.minZoomLevel = 5
        view.mapView.maxZoomLevel = 20
        
        view.mapView.latitude = mapController.locationManager.location?.coordinate.latitude ?? 0
        view.mapView.longitude = mapController.locationManager.location?.coordinate.longitude ?? 0
        // 실내 지도 모드 활성화
        view.mapView.isIndoorMapEnabled = true
        
        // 현재 위치 포커스 버튼 활성화
        view.showLocationButton = true
        
        
        let circle = NMFCircleOverlay()
        circle.center = NMGLatLng(lat: circleCenter.latitude, lng: circleCenter.longitude)
        // 미터 단위로 원이 그려집니다.
        circle.radius = circleRadius
        circle.outlineColor = UIColor(Color.customCircleOutlineRed)
        circle.fillColor = UIColor(Color.customCircleFillRed)
        circle.mapView = view.mapView
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    

}

class NaverMapViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = NMFMapView(frame: view.frame)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
            
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0))
            cameraUpdate.animation = .easeIn
            mapView.moveCamera(cameraUpdate)
            
        } else {
            print("위치 서비스 off")
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 모임 위치와의 거리 계산
        
        print(location)
    }
}


class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate, NMFMapViewOptionDelegate {
    
}

extension CLLocation {
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Int {
        distance(from: CLLocation(latitude: from.latitude, longitude: from.longitude))
        return 1
    }
}
