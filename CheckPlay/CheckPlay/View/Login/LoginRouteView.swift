//
//  LoginRouteView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/02.
//

import SwiftUI
import FirebaseAuth

/// 로그인 상태에 따라 보여지는 뷰를 분기처리합니다.
struct LoginRouteView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var attendanceStore: AttendanceStore
    
    // 런치스크린을 실행할지 판단하는 변수입니다.
    @State var isPresentedLaunchScreen: Bool = true
    var body: some View {
        NavigationView {
            if isPresentedLaunchScreen {
                LauchScreenView()
            }
            else if userStore.isLogin {
                ContentView()
            } else {
                LoginView()
            }
            
        } // - NavigationView
        .task {
            // 이미 로그인한 상태면
            guard let currentUser = Auth.auth().currentUser
            else {
                isPresentedLaunchScreen = false
                return
            }
            await userStore.fetchUser(uid: currentUser.uid)
            await scheduleStore.fetchScheduleOnToday()
            
            if scheduleStore.scheduleOfToday != nil && userStore.currentUser != nil {
                let foundAttendanceIDResult = await attendanceStore.findAttendanceWithScheduleID(scheduleID: scheduleStore.scheduleOfToday!.id, studentCode: userStore.currentUser!.studentCode)
                
                switch foundAttendanceIDResult {
                case .success(let attendanceID):
                    let fetchResult = await attendanceStore.fetchAttendance(attendanceID: attendanceID)
                    
                    switch fetchResult {
                    case .success(let attendance):
                        attendanceStore.attendanceOfToday = attendance
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    }
                    
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
            userStore.isLogin = true
            isPresentedLaunchScreen = false
        }
    } 
}

