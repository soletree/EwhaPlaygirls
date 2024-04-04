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
            return Color.green
        case .late:
            return Color.yellow
        case .absent:
            return Color.red
        case .officialAbsent:
            return Color.black
        case .cancledByWeather:
            return Color.blue
        case .cancledByCoach:
            return Color.blue
        case .rest:
            return Color.purple
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
            return "출석체크 시간이 아니에요"
        case .location:
            return "지정된 위치가 아니에요"
        case .complete:
            return "출석체크가 이미 완료되었어요"
        case .unknown:
            return "알 수 없는 오류예요. 개발자에게 문의해주세요."
        case .noSchedule:
            return "오늘은 일정이 없어요"
        @unknown default:
            return "알 수 없는 오류입니다! 개발자에게 문의해주세요."
        }
    }
}
