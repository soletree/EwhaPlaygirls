//
//  CheckPlayApp.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct CheckPlayApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userStore: UserStore = .init()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginRouteView()
                    .environmentObject(userStore)
                    .task {
                        // 이미 로그인한 상태면
                        guard let currentUser = Auth.auth().currentUser else { return }
                        await userStore.fetchUser(uid: currentUser.uid)
                        userStore.isLogin = true
                    }
            }
        }
    }
}

