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
}

extension String {
    
}
