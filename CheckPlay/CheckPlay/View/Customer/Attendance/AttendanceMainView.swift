//
//  AttendanceMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import SwiftUI
import GoogleMobileAds

struct AttendanceMainView: View {
    @EnvironmentObject var attendanceStore: AttendanceStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            if attendanceStore.attendances.isEmpty {
                Spacer()
                EmptyAttendanceView()
            } else {
                
                List {
                    ForEach(attendanceStore.attendances, id: \.self.id) { attendance in
                        AttendanceRow(attendance: .constant(attendance))
                    }
                }
            }
            Spacer()
            
            
            // 광고 부분입니다. 
            GoogleAdView()
                .frame(width: UIScreen.main.bounds.width,
                       height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
            
                .navigationTitle("출석현황")
                .navigationBarTitleDisplayMode(.large)
        } // - VStack
        .task {
            await attendanceStore.fetchAttendances(studentCode: userStore.currentUser?.studentCode ?? "")
        }
        .refreshable {
            Task {
                await attendanceStore.fetchAttendances(studentCode: userStore.currentUser?.studentCode ?? "")
            }
        }
    }
}

struct AttendanceDetailView: View {
    @Binding var attendance: Attendance
    var body: some View {
        VStack {
            Text("\(attendance.studentCode)")
            Text("\(attendance.date)")
            Text("\(attendance.attendanceStatus.rawValue)")
        }
    }
}


struct AttendanceRow: View {
    @Binding var attendance: Attendance
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(attendance.date.toStringUntilDay())")
                Text("\(attendance.date.toStringOnlyHourAndMinute())")
                    .font(.callout)
                    .foregroundColor(.customGray)
            }
            Spacer()
            
            // 출결 상태
            VStack {
                Text("\(attendance.attendanceStatus.rawValue)")
                    .foregroundColor(AttendanceStatusComponentSetting(attendanceStatus: attendance.attendanceStatus).color)
                    .bold()
                // 지각이면 지각한 시간도 함께 표시합니다.
                if attendance.attendanceStatus == .late {
                    Text("\(attendance.lateTime)분")
                        .bold()
                }
            } // - VStack
                
        } // - HStack
    }
    
}
