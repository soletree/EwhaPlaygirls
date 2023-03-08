//
//  AttendanceMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import SwiftUI

struct AttendanceMainView: View {
    @EnvironmentObject var attendanceStore: AttendanceStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            List {
                ForEach(attendanceStore.attendances, id: \.self.id) { attendance in
                    AttendanceRow(attendance: .constant(attendance))
                }
            }
        } // - VStack
        .task {
            await attendanceStore.fetchAttendance(studentCode: userStore.currentUser?.studentCode ?? "")
        }
        .refreshable {
            Task {
                await attendanceStore.fetchAttendance(studentCode: userStore.currentUser?.studentCode ?? "")
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

struct AttendanceStatusComponentSetting {
    var attendanceStatus: AttendanceStatus
    var color: Color {
        switch attendanceStatus {
        case .attendance:
            return .green
        case .late:
            return .orange
        case .absent:
            return .red
        case .officialAbsent:
            return .black
        case .cancledByWeather:
            return .indigo
        case .cancledByCoach:
            return .indigo
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
            
            Text("\(attendance.attendanceStatus.rawValue)")
                .foregroundColor(AttendanceStatusComponentSetting(attendanceStatus: attendance.attendanceStatus).color)
                .bold()
                
                .navigationTitle("출석현황")
        }
    }
    
}
