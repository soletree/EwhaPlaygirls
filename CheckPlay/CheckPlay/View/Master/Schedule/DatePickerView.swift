//
//  DatePickerView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/05.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var date: Date
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2019, month: 1, day: 1)
        let endcomponents = DateComponents(year: 2030, month: 12, day: 31)
        return calendar.date(from: startComponents)!
            ...
            calendar.date(from: endcomponents)!
    }()
    
    var body: some View {
            DatePicker("일시",
                       selection: $date,
                       in: dateRange,
                       displayedComponents: [.date, .hourAndMinute]
            )
            .frame(width: UIScreen.screenWidth * 0.8)
        
    }
}
