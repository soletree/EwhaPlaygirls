//
//  AttendanceStatusComponentSetting.swift
//  CheckPlay
//
//  Created by sole on 2023/04/11.
//

import SwiftUI

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
