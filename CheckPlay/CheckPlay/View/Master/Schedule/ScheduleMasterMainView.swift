//
//  ScheduleMainView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/04.
//

import SwiftUI
import AlertToast
import GoogleMobileAds

struct ScheduleMasterMainView: View {
    @EnvironmentObject var scheduleStore: ScheduleMasterStore
    
    @State var isPresentedAddScheduleSheet: Bool = false
    @State var isPresentedAddScheduleAlert: Bool = false
    
    let filterStandard = ["최신순", "오래된 순"]
    @State var selectedStandard: String = "최신순"
    
    
    @State var schedules: [Schedule] = []
    
    var body: some View {
        VStack {
            List {
                ForEach(schedules, id: \.self.id) { schedule in
                    NavigationLink(destination: ScheduleEditModeRouteView(schedule: schedule)) {
                        VStack(alignment: .leading) {
                            Text("\(schedule.date.toStringUntilDay())")
                                .bold()
                            Text("\(schedule.date.toStringOnlyHourAndMinute())")
                                
                            if (!schedule.address.isEmpty || !schedule.detailedAddress.isEmpty) {
                                Text("\(schedule.address) \(schedule.detailedAddress)")
                            }
                        } // - VStack
                    } // - NavigationLink
                } // - ForEach
            } // - List
            
            // 광고 부분입니다.
            GoogleAdView()
                .frame(width: UIScreen.main.bounds.width,
                       height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
            
            .onReceive(scheduleStore.$schedules) { output in
                schedules = output
            }
            .refreshable {
                selectedStandard = filterStandard[0]
                Task {
                    await scheduleStore.fetchSchedules()
                }
            }
            
            .toolbar {
                Picker("", selection: $selectedStandard) {
                    ForEach(filterStandard, id: \.self) {
                        Text($0)
                    }
                }
                
                Button(action: {
                    isPresentedAddScheduleSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .navigationBarTitle("일정관리")
        } // - VStack
        .task {
            await scheduleStore.fetchSchedules()
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
        
        .sheet(isPresented: $isPresentedAddScheduleSheet) {
            AddScheduleView(isPresentedAddScheduleAlert: $isPresentedAddScheduleAlert)
        }
        .toast(isPresenting: $isPresentedAddScheduleAlert) {
            AlertToast(displayMode: .alert,
                       type: .complete(.green),
                       title: "일정 등록이 완료되었습니다.")
        }
    }
}


//MARK: - ScheduleDetailView
struct ScheduleDetailView: View {
    @Binding var schedule: Schedule
    @Binding var isEditingMode: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(schedule.date.toStringUntilDay())")
                .font(.title.bold())
            Text("\(schedule.date.toStringOnlyHourAndMinute())")
                .bold()
            
            Text("\(schedule.address)")
            Text("\(schedule.detailedAddress)")
            
            
            Spacer()
            ScheduleMapDetailMasterView(center: .constant(.init(latitude: schedule.latitude,
                                                                longitude: schedule.longitude)))
            .frame(width: UIScreen.screenWidth * 0.9,
                   height: UIScreen.screenWidth * 0.9)
            
            Spacer()
            
                .toolbar {
                    Button(action: {
                        isEditingMode = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            
        } // - VStack
        .padding(10)
    }
} // - ScheduleDetailView

struct ScheduleEditModeRouteView: View {
    @State var isEditingMode: Bool = false
    @State var schedule: Schedule
    
    var body: some View {
        VStack {
            if !isEditingMode {
                ScheduleDetailView(schedule: $schedule,
                                   isEditingMode: $isEditingMode)
            } else {
                EditScheduleView(schedule: $schedule,
                                 isEditingMode: $isEditingMode)
            }
        }
    }
}
