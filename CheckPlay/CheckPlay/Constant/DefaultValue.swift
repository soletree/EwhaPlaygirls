//
//  DefaultValue.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import Foundation

/// nil 값의 default 값으로 사용되는 상수들입니다.
struct DefaultValue {
    static let defaultString = "unknown"
    static let defultAttendance: Attendance = .init(id: "unknown",
                                                    studentCode: "unknown",
                                                    scheduleID: "unknown",
                                                    attendanceStatus: .absent,
                                                    lateTime: 0,
                                                    isPaying: false,
                                                    date: Date())
    static let defaultSchedule: Schedule = .init(id: "unknown",
                                                 date: Date(),
                                                 latitude: 0,
                                                 longitude: 0,
                                                 address: "unknown",
                                                 detailedAddress: "unknown")
}
