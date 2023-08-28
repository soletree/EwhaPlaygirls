//
//  AttendanceMasterMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import SwiftUI
import GoogleMobileAds

struct AttendanceMasterMainView: View {
    
    @EnvironmentObject var memberStore: MemberMasterStore
    @EnvironmentObject var scheduleStore: ScheduleMasterStore
    @EnvironmentObject var attendanceStore: AttendanceMasterStore
    
    let filterStandard = ["최신순", "오래된 순"]
    @State var selectedStandard: String = "최신순"
    
    @State var schedules: [Schedule] = []
    var body: some View {
        VStack {
            List {
                ForEach(schedules, id: \.self.id) { schedule in
                    NavigationLink(destination:
                                    AttendanceMasterDetailView(scheduleID: schedule.id,
                                                         date: schedule.date)
                                    .environmentObject(memberStore)
                                    .environmentObject(scheduleStore)
                                    .environmentObject(attendanceStore)) {
                                        VStack(alignment: .leading) {
                                            Text("\(schedule.date.toStringUntilDay())")
                                                .bold()
                                            Text("\(schedule.date.toStringOnlyHourAndMinute())")
                                        } // - VStack
                    }
                }
            }
            
            // 광고 부분입니다.
            GoogleAdView()
                .frame(width: UIScreen.main.bounds.width,
                       height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
            
            .onReceive(scheduleStore.$schedules) { output in
                schedules = output
            }
            .toolbar {
                Picker("", selection: $selectedStandard) {
                    ForEach(filterStandard, id: \.self) {
                        Text($0)
                    }
                }
            }
            .refreshable {
                selectedStandard = filterStandard[0]
                Task {
                    await scheduleStore.fetchSchedules()
                }
            }
            .onChange(of: selectedStandard) { newValue in
                // 최신순
                if selectedStandard == filterStandard[0] {
                    schedules = scheduleStore.schedules.sorted { $0.date > $1.date }
                // 오래된 순
                } else if selectedStandard == filterStandard[1] {
                    schedules = scheduleStore.schedules.sorted { $0.date < $1.date }
                } else {
                    schedules = scheduleStore.schedules
                }
            }
            .navigationBarTitle("출결관리")
        } // - VStack
        
    }
}
