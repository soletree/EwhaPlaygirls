//
//  Attendance.swift
//  CheckPlay
//
//  Created by sole on 2023/03/06.
//

import SwiftUI

enum AttendanceStatus: String {
    case attendance = "출석" // 출석
    case late = "지각" // 지각
    case absent = "결석" // 결석
    case officialAbsent = "공결" // 공결
    case cancledByWeather = "우천 취소" // 우천 취소
    case cancledByCoach = "감독 취소" // 감독 취소
    case rest = "휴동" // 휴동
    
    func toColor() -> Color {
        switch self {
        case .attendance:
            return Color.pointColor
        case .late:
            return Color.pointColor
        case .absent:
            return Color.pointColor
        case .officialAbsent:
            return Color.pointColor
        case .cancledByWeather:
            return Color.pointColor
        case .cancledByCoach:
            return Color.pointColor
        case .rest:
            return Color.pointColor
        }
    }
}


struct Attendance {
    var id: String //식별자
    var studentCode: String // 학번
    var scheduleID: String // 스케줄 id
    var attendanceStatus: AttendanceStatus // 출결 상태 (기본은 결석)
    var lateTime: Int // 지각한 시간(분)
    var isPaying: Bool // 지각비 정산 여부
    var date: Date
    
    static let defaultModel = Attendance(id: "unknown",
                                         studentCode: "unknown",
                                         scheduleID: "unknown",
                                         attendanceStatus: .absent,
                                         lateTime: 0,
                                         isPaying: false,
                                         date: Date())
}

enum AttendanceError: Error {
    case time
    case location
    case complete
    case unknown
    case noSchedule
    
    func toString() -> String {
        switch self {
        case .time:
            return "출석체크 시간이 아닙니다!"
        case .location:
            return "지정된 위치가 아닙니다."
        case .complete:
            return "출석체크가 완료되었습니다!"
        case .unknown:
            return "알 수 없는 오류입니다! 개발자에게 문의하세요."
        case .noSchedule:
            return "오늘은 일정이 없습니다!"
        @unknown default:
            return "알 수 없는 오류입니다! 개발자에게 문의하세요."
        }
    }
}
