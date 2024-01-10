//
//  CheckPlayApp.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth
import NMapsMap
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        NMFAuthManager.shared().clientId = "\(Bundle.main.object(forInfoDictionaryKey: "NAVER_API_CLIENT_ID") ?? "")"
        
        return true
    }
}

@main
struct CheckPlayApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userStore: UserStore = .init()
    @StateObject var scheduleStore: ScheduleStore = .init()
    @StateObject var attendanceStore: AttendanceStore = .init()
    @StateObject var requestStore: RequestStore = .init()
    var body: some Scene {
        WindowGroup {
            
            LoginRouteView()
                    .accentColor(.brandColor)
                    .environmentObject(userStore)
                    .environmentObject(scheduleStore)
                    .environmentObject(attendanceStore)
                    .environmentObject(requestStore)
                    
            
        }
    }
}

