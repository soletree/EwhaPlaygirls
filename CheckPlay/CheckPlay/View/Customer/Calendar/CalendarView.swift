//
//  ContentView.swift
//  CalendarDemo
//
//  Created by sole on 1/8/24.
//

import SwiftUI

let dayofWeek: [Int] = Array(WeekDay.sunday.rawValue...WeekDay.saturday.rawValue)

struct CalendarView: View {
    @ObservedObject var calendar: CalendarViewModel = .init()
    @State var selectedDate: DateComponents = .init()
    
    var body: some View {
        VStack(alignment: .center,
               spacing: 10) {
            calendarHeader
            calendarBody
                .padding(.horizontal, 20)
            Spacer()
        }
        .overlay(alignment: .bottomLeading) {
            selectedDateView
        }
        .onAppear {
            calendar.year = calendar.nowDateComponent.year ?? calendar.yearRange.lowerBound
            calendar.month = calendar.nowDateComponent.month ?? calendar.monthRange.lowerBound
            selectedDate = calendar.nowDateComponent
        }
    }
    
    //MARK: - calendarHeader
    private var calendarHeader: some View {
        HStack {
            Button {
                calendar.prevMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.black)
            }
            
            Spacer()
            
            Text("\(String(calendar.year))년 \(calendar.month)월")
                .pretendard(size: .l,
                            weight: .bold)
                
            Spacer()
            
            Button {
                calendar.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.black)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color.subColor300)
    }
    
    //MARK: - calendarBody
    private var calendarBody: some View {
        Grid(alignment: .center,
             horizontalSpacing: 5,
             verticalSpacing: 3) {
            
            //MARK: - 요일 label section
            GridRow(alignment: .center) {
                ForEach(dayofWeek,
                        id: \.self) { day in
                    Text("\(WeekDay(rawValue: day)?.getString() ?? "")")
                        .pretendard(size: .s,
                                    weight: .semibold)
                }
            }
            .padding(.vertical, 10)
            
            // 날짜 section
            ForEach(calendar.divideDaysInWeek, id: \.self) { dateList in
                GridRow {
                    ForEach(dateList, id: \.self) { dateComponent in
                        
                        DateComponent(selected: $selectedDate,
                                      dateComponent: dateComponent,
                                      attendance: nil) {
                            // attendance date fetch
                            selectedDate = dateComponent
                        }
                        
                    }
                }
            }
        }
    }
    
    //MARK: - selectedDateView
    private var selectedDateView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(selectedDate.date?.dateToString ?? Date.now.dateToString)")
                    .pretendard(size: .l, weight: .semibold)
                    .padding(.vertical, 20)
                Spacer()
                
                Button {
                    selectedDate = calendar.nowDateComponent
                    calendar.resetToCurrentDate()
                } label: {
                    Image(systemName: "arrow.rectanglepath")
                        .foregroundStyle(.black)
                }
            }
            Text("출석")
                .pretendard(size: .m,
                            weight: .medium)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 250)
        .background(
         LinearGradient(colors: [.gray100, .white], startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(15)
    }
    
}


#Preview {
    CalendarView()
}


