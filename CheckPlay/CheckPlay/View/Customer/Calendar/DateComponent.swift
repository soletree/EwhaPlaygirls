//
//  DateComponent.swift
//  CalendarDemo
//
//  Created by sole on 1/8/24.
//

import SwiftUI

struct DateComponent: View {
    @Binding var selected: DateComponents
    
    var dateComponent: DateComponents?
    var isValid: Bool {
        guard let date = dateComponent
        else { return false }
        
        return date.isValidDate
    }
    var attendance: Attendance?
    var action: () -> () = {}
    
    var isSelected: Bool {
        guard let date = dateComponent
        else { return false }
        return date.compare(selected)
    }
    
    var backgrounColor: Color {
        guard isValid
        else { return .clear }

        guard let dateComponent
        else { return .clear }
        if isSelected {
            return .gray200
        }
        
        return .white
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text("\(dateComponent?.day ?? 0)")
                    .pretendard(size: .xxs,
                                weight: .regular)
                    .foregroundStyle(isValid ? .black : .clear)
                
                Circle()
                    .foregroundStyle(isValid && (attendance != nil) ? attendance?.attendanceStatus.toColor() ?? .clear : .clear)
                    .frame(width: 10,
                           height: 10)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(backgrounColor)
            .cornerRadius(100)
        }
        .disabled(!isValid)
    }
}

#Preview {
    DateComponent(selected: .constant(.init()),
                  dateComponent: DateComponents.init(calendar: Calendar.current,
                                            year: 2023,
                                            month: 10,
                                            day: 12),
                  attendance: nil)
}
