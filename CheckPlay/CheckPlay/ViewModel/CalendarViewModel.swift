//
//  CalendarViewModel.swift
//  CalendarDemo
//
//  Created by sole on 1/8/24.
//

import SwiftUI

class CalendarViewModel: ObservableObject {
    let yearRange: Range = 2021..<Calendar.current.component(.year,
                                                             from: .now) + 5
    let monthRange: ClosedRange = 1...12
    let dayRange: ClosedRange = 1...31
    
    let calendar: Calendar = .init(identifier: .gregorian)
    let days: [Int] = Array(1...31)
    
    var nowDateComponent: DateComponents {
        let component = calendar.dateComponents([.year,
                                 .month,
                                 .day,
                                 .weekday],
                           from: .now)
        return component
    }
    
    @Published var year: Int = 2021
    @Published var month: Int = 1
    
    var dateComponents: [DateComponents] {
        return daysinMonth(year: year,
                           month: month)
    }
    
    var divideDaysInWeek: [[DateComponents]] {
        return divideDaysInWeek(dateComponents: dateComponents)
    }
    
    
    //MARK: - Control Calendar
    
    // 이전 월로 넘어가는 메서드입니다.
    func prevMonth() {
        if month == 1 {
            if year == Int(yearRange.lowerBound) {
                return
            }
            month = 12
            year -= 1
        } else {
            month -= 1
        }
    }
    
    // 다음 Month로 넘어가는 메서드입니다.
    func nextMonth() {
        // 현재 month가 12월인 경우
        if month == 12 {
            if year == Int(yearRange.upperBound) {
                return
            }
            // 다음 년도 1월로 설정
            month = 1
            year += 1
        } else {
            month += 1
        }
    }
    
    func resetToCurrentDate() {
        month = nowDateComponent.month ?? monthRange.lowerBound
        year = nowDateComponent.year ?? yearRange.lowerBound
    }
    
    func daysinMonth(year: Int,
                     month: Int) -> [DateComponents] {
        var dateComponents: [DateComponents] = []
        days.forEach { day in
            var dateComponent = DateComponents(year: year,
                                              month: month,
                                              day: day,
                                               hour: 0)
            dateComponent.calendar = calendar
            guard dateComponent.isValidDate
            else { return }
            dateComponent.weekday = findWeekday(year: year,
                                                month: month,
                                                day: day)
            dateComponents.append(dateComponent)
        }
        
        return dateComponents
    }
    
    func findWeekday(year: Int,
                     month: Int,
                     day: Int) -> Int? {
        var dateComponent = DateComponents(year: year,
                                          month: month,
                                          day: day)
        dateComponent.calendar = calendar
        guard dateComponent.isValidDate
        else { return nil }
        let weekday = calendar.component(.weekday,
                                         from: dateComponent.date ?? .now)
        return weekday
    }
    
    //MARK: - divideDaysInWeek
    // 같은 주의 날짜들을 같은 배열에 넣는 메서드입니다.
    func divideDaysInWeek(dateComponents: [DateComponents]) -> [[DateComponents]] {
        var result: [[DateComponents]] = []
        
        var components: [DateComponents] = Array(repeating: DateComponents(),
                                                 count: 7)
        
        for dateComponent in dateComponents {
            components[(dateComponent.weekday ?? 1) - 1] = dateComponent
            
            if dateComponent.weekday == 7 {
                result.append(components)
                components = Array(repeating: DateComponents(),
                                   count: 7)
            }
        }
        if result.last ?? [] != components {
            result.append(components)
        }
        
        return result
    }
}

extension DateComponents {
    var dayOftheWeek: String {
        guard let weekday = self.weekday
        else { return "" }
        return WeekDay(rawValue: weekday)?.getString() ?? "-"
    }
    
    func compare(_ to: DateComponents) -> Bool {
        if self.year == to.year,
           self.month == to.month,
           self.day == to.day {
            return true
        }
        return false
    }
}

enum WeekDay: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    func getString() -> String {
        switch self {
        case .sunday:
            return "일"
        case .monday:
            return "월"
        case .tuesday:
            return "화"
        case .wednesday:
            return "수"
        case .thursday:
            return "목"
        case .friday:
            return "금"
        case .saturday:
            return "토"
        }
    }
}
