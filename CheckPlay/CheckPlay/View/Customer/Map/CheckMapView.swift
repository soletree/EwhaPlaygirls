//
//  CheckMapView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import NMapsMap
import CoreLocation
import AlertToast

struct CheckMapView: View {
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var attendanceStore: AttendanceStore
    var circleCenter: CLLocationCoordinate2D = .init(latitude: 37, longitude: 126)
    var circleRadius: Double = 30
    var locationManager = CLLocationManager()
    @State var isPresentedAttendanceAlert: Bool = false
    @State var attendanceAlert = AlertToast(displayMode: .alert,
                                            type: .complete(.green))
    
    
    var body: some View {
        VStack {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                checkMapView
            case .denied, .notDetermined, .restricted:
                checkLocationAuthorization
            }
        } // - VStack
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .toast(isPresenting: $isPresentedAttendanceAlert) {
            attendanceAlert
        }
    }
    
    private var checkLocationAuthorization: some View {
        Button(action: {
            locationManager.requestWhenInUseAuthorization()
        }) {
            Image(systemName: "location.square.fill")
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.5, height: UIScreen.screenWidth * 0.5)
        }
    }
    
    private var checkMapView: some View {
        VStack {
            NaverMapView(circleCenter: circleCenter, circleRadius: circleRadius)
            
//            CustomButton(style: .check) {
//                switch isVaildCheck() {
//                case .success(let result):
//                    Task {
//                        guard let attendanceOfToday = attendanceStore.attendanceOfToday
//                        else { return }
//                        
//                        // remote 변경 사항
//                        guard await attendanceStore.updateAttendance(attendanceID: attendanceOfToday.id, attendanceStatus: result.0, lateTime: result.1)
//                        else { return }
//                        
//                        
//                        // local 변경 사항
//                        attendanceStore.attendanceOfToday?.attendanceStatus = result.0
//                        attendanceStore.attendanceOfToday?.lateTime = result.1
//                        
//                        // alert 처리
//                        attendanceAlert.type = .complete(.green)
//                        attendanceAlert.title = "출석체크가 완료되었습니다."
//                        isPresentedAttendanceAlert = true
//                    }
//                case .failure(let error):
//                    // error typing
//                    switch error {
//                    case .location:
//                        attendanceAlert.title = "지정된 위치가 아닙니다.\n \(locationManager.location?.distance(to: circleCenter) ?? 0)m 이동해주세요!"
//                    case .time:
//                        attendanceAlert.title = "출석체크 시간이 아닙니다!"
//                    case .complete:
//                        attendanceAlert.title = "이미 출석체크가 완료되었습니다!"
//                    case .unknown:
//                        attendanceAlert.title = "알 수 없는 오류입니다! 개발자에게 문의하세요."
//                    case .noSchedule:
//                        attendanceAlert.title = "오늘은 일정이 없습니다!"
//                    }
//                    
//                    attendanceAlert.type = .regular
//                    isPresentedAttendanceAlert = true
//                }
//            }.customButton
//                .padding(.vertical, 20)
        }
    } // - checkMapView
    
    private func isVaildCheck() -> Result<(AttendanceStatus, Int),AttendanceError> {
        guard let attendanceOfToday = attendanceStore.attendanceOfToday
        else { return .failure(.noSchedule) }
        
        if attendanceOfToday.attendanceStatus != .absent {
            return .failure(.complete)
        }
        
        guard let currentLocation = locationManager.location
        else { return .failure(.unknown) }
        // time 조건
        guard let comparedDate = scheduleStore.scheduleOfToday?.date else { return .failure(.noSchedule) }
        
        guard let timeComparedResult = Date().compareToSpecificDate(compared: comparedDate)
        else { return .failure(.time) }
        
        
        // 모임 장소로부터 거리가 20m 초과일시 출석체크하지 않습니다.
        if currentLocation.distance(to: circleCenter) > 20 {
            return .failure(.location)
        }
        
        
        return .success(timeComparedResult)
    }
        
}

enum AttendanceError: Error {
    case time
    case location
    case complete
    case unknown
    case noSchedule
}


struct NaverMapView: UIViewRepresentable {
    let mapController: NaverMapViewController = .init()
    var circleCenter: CLLocationCoordinate2D
    var circleRadius: Double
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()

        view.mapView.positionMode = .compass
        
        view.mapView.allowsZooming = true
        view.mapView.zoomLevel = 15
        view.mapView.minZoomLevel = 5
        view.mapView.maxZoomLevel = 20
        
        // 현재 위치 focus
        view.mapView.latitude = mapController.locationManager.location?.coordinate.latitude ?? 0
        view.mapView.longitude = mapController.locationManager.location?.coordinate.longitude ?? 0
        // 실내 지도 모드 활성화
        view.mapView.isIndoorMapEnabled = true
        
        // 현재 위치 포커스 버튼 활성화
        view.showLocationButton = true
        
        // 모임 장소에 핀을 꽂습니다.
        let pin = NMFMarker(position: NMGLatLng(lat: circleCenter.latitude, lng: circleCenter.longitude))
        pin.mapView = view.mapView
        
        let circle = NMFCircleOverlay()
        circle.center = NMGLatLng(lat: circleCenter.latitude, lng: circleCenter.longitude)
        // 미터 단위로 원이 그려집니다.
        circle.radius = circleRadius
        circle.outlineColor = UIColor(Color.mapCircleOutlineRed)
        circle.fillColor = UIColor(Color.mapCircleFilledRed)
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
        checkLocationAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
           
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.locationManager.location?.coordinate.latitude ?? 0, lng: self.locationManager.location?.coordinate.longitude ?? 0))
            cameraUpdate.animation = .easeIn
            mapView.moveCamera(cameraUpdate)
            
        } else {
            print("위치 서비스 off")
        }
        
        
    }
    
    func checkLocationAuthorization() {
        switch self.locationManager.authorizationStatus {
        case .restricted, .notDetermined, .denied, .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        default:
            return
        }
    }

}




class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate, NMFMapViewOptionDelegate {
    
}

extension CLLocation {
    
    func distance(to: CLLocationCoordinate2D) -> Int {
        return Int(self.distance(from: CLLocation(latitude: to.latitude, longitude: to.longitude)))
    }
}
