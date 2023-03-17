//
//  CheckMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import MapKit

struct CheckMainView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var attendanceStore: AttendanceStore
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37, longitude: 128), latitudinalMeters: 500, longitudinalMeters: 500)
    @State var isActiveNFCSheet: Bool = false
    var scheduleOfToday: Schedule? {
        scheduleStore.scheduleOfToday
    }
    var circleCenter: CLLocationCoordinate2D {
        if scheduleOfToday == nil {
            return .init(latitude: 0, longitude: 0)
        } else {
            return scheduleOfToday!.location
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 현재 날짜
            Text("\(Date().toStringUntilDay())")
                .font(.title.bold())
                .padding(10)
            
            if scheduleStore.scheduleOfToday != nil {
                Text(scheduleOfToday!.date.toStringOnlyHourAndMinute())
                Text("\(scheduleOfToday!.address)")
                     +
                Text("\(scheduleOfToday!.detailedAddress)")
                    
            } else {
                Text("오늘은 일정이 없습니다.")
                    .padding(10)
            }
                
            
            // 지도
            CheckMapView(circleCenter: circleCenter)
    
//            // nfc 버튼
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            isActiveNFCSheet = true
                        }) {
                            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                        }
                    }
                }
//               
        } // - VStack
        .sheet(isPresented: $isActiveNFCSheet) {
            if #available (iOS 16.0, *) {
                Text("NFC")
                    .presentationDetents([.medium])
            } else {
                Text("NFC")
            }
        }

    }
}

