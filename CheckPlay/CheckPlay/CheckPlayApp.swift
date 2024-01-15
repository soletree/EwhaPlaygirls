//
//  CheckPlayApp.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import NMapsMap
import AppTrackingTransparency
import FirebaseMessaging

class AppDelegate: NSObject,
                   UIApplicationDelegate,
                   MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        // fcmtoken 자동 설정 해제
        Messaging.messaging().isAutoInitEnabled = true
        
        NMFAuthManager.shared().clientId = "\(Bundle.main.object(forInfoDictionaryKey: "NAVER_API_CLIENT_ID") ?? "")"
        
        // register divice to APNs
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { didAllow, error in
            if let error {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }
    
//    /// APNs deviceToken을 등록 성공했을 때 실행되는 메서드입니다.
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        print("didRegisterForRemoteNotificationsWithDeviceToken")
//        let token = deviceToken.reduce("") {
//            $0 + String(format: "%02X", $1)
//        }
//        print(token)
//    }
   
    /// APNs deviceToken 등록 실패 시 실행되는 메서드입니다.
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    /// FCM token을 등록 성공했을 때 실행되는 메서드입니다.
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        // 주제 구독
        Messaging.messaging().subscribe(toTopic: "attendance") { error in
            if let error = error {
                print(error.localizedDescription)
            }
          print("Subscribed to topic")
        }
    }
    
    
}

@main
struct CheckPlayApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
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

