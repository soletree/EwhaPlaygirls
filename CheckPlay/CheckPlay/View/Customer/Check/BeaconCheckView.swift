//
//  BeaconCheckView.swift
//  CheckPlay
//
//  Created by sole on 1/30/24.
//

import SwiftUI
import CoreLocation
import SnapKit
import Lottie

struct BeaconCheckView: UIViewControllerRepresentable {
    @Binding var userRegion: CLRegionState
    
    func makeUIViewController(context: Context) -> some UIViewController {
        BeaconCheckViewController(userRegion: $userRegion)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: Context) {
    }
}

class BeaconCheckViewController: UIViewController,
                                 CLLocationManagerDelegate {
    @Binding var userRegion: CLRegionState
    
    private var locationManager: CLLocationManager!
    
    private var animationView: LottieAnimationView!
    private var insideAnimationView: LottieAnimationView!
    private var outsideAnimationView: LottieAnimationView!
    
    private var beaconRegion: CLBeaconRegion {
        let beaconString: String = Bundle.main.infoDictionary?["BeaconUUID"] 
            as? String ?? ""
        let beaconIdentifier = Bundle.main.infoDictionary?["BeaconID"]
        as? String ?? ""
        
        let beaconUUID = UUID(uuidString: beaconString) ?? .init()
        let constraint = CLBeaconIdentityConstraint(uuid: beaconUUID)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint,
                                          identifier: beaconIdentifier)
        return beaconRegion
    }
    
    // 이니셜라이저 수정
    init(userRegion: Binding<CLRegionState>) {
        self._userRegion = userRegion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = .init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
        
        setViews()
        addViews(view)
        setLayout()
    
        startMonitoringBeacon()
    }
    
    func setViews() {
        animationView = LottieAnimationView()
        animationView.animation = .named("unfinding-beacon")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.backgroundBehavior = .pauseAndRestore
    }
    
    func addViews(_ view: UIView) {
        [animationView]
            .forEach { subView in
                view.addSubview(subView)
            }
    }
    
    func setLayout() {
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }
    
    func setInsideView() {
        animationView.animation = .named("finding-beacon")
        animationView.play()
    }
    
    func setOutsideView() {
        animationView.animation = .named("unfinding-beacon")
        animationView.play()
    }
    
    func startMonitoringBeacon() {
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
        else {
            // Error notify
            print("불가능")
            return
        }
        
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyEntryStateOnDisplay = true
        
        locationManager.startMonitoring(for: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        print("enter")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        print("exit")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        // error notification
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
        switch state {
        case .inside:
            userRegion = .inside
            setInsideView()
        case .outside:
            userRegion = .outside
            setOutsideView()
        case .unknown:
            userRegion = .unknown
            setOutsideView()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return
        case .notDetermined, .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            locationManager.requestAlwaysAuthorization()
        }
    }
}

extension CLRegionState {
    func toString() -> String {
        switch self {
        case .inside:
            return "안"
        case .outside:
            return "밖"
        case .unknown:
            return "밖"
        }
    }
}


#Preview {
    BeaconCheckView(userRegion: .constant(.inside))
}
