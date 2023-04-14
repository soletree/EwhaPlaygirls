//
//  Ex+Date.swift
//  CheckPlay
//
//  Created by sole on 2023/03/07.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        return dateFormatter.string(from: self)
    }
    
    func toStringUntilDay() -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 E요일"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        return dateFormatter.string(from: self)
    }
    
    func toStringOnlyHourAndMinute() -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "a hh시 mm분"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        return dateFormatter.string(from: self)
    }
    
    func returnDateOfToday() -> (Int, Int, Int) {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: self)) ?? 0
        dateFormatter.dateFormat = "MM"
        let month = Int(dateFormatter.string(from: self)) ?? 0
        dateFormatter.dateFormat = "dd"
        let day = Int(dateFormatter.string(from: self)) ?? 0
                       
        return (year, month, day)
                       
    }
    
    /// 특정 Date와 시간을 비교하는 메서드입니다.
    /// - return: (출석 상태, 지각한 시간)
    /// - 만일 출석 시간보다 15분 보다 이른 시간이면 nil을 반환합니다. 
    func compareToSpecificDate(compared date: Date) -> (AttendanceStatus, Int)? {
        // 15분 전부터 출석체크가 가능합니다.
        let startDate = date.addingTimeInterval(-15 * 60)
        // 10분 후부터 지각처리됩니다.
        let lateDate = date.addingTimeInterval(10 * 60)
        
        // 15분보다 더 이전이면 출석체크하지 않습니다.
        if self < startDate {
            return nil
        }
        // 출석 시간 내에 출석하면 출석
        else if self <= lateDate {
            return (AttendanceStatus.attendance, 0)
        }
        // 2시간까지는 지각 처리 됩니다.
        else if self < date.addingTimeInterval(2 * 60 * 60) {
            let interval = self.timeIntervalSince(date) / 60.0
            return (AttendanceStatus.late, Int(interval))
        // 2시간 이후엔 결석처리 됩니다.
        } else {
            return nil
        }
        
        
        
        
    }
    
}





extension String {
    
}
