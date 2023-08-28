//
//  AttendanceMasterDetailView.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import SwiftUI
import AlertToast
import GoogleMobileAds

struct AttendanceMasterDetailView: View {
    @EnvironmentObject var memberStore: MemberMasterStore
    @EnvironmentObject var attendanceStore: AttendanceMasterStore
    
    let scheduleID: String
    let date: Date
    
    var keys: [String] {
        Array(
            attendanceStore
            .scheduleIDAndAttendanceDictionary
            .keys
        )
        .sorted { $0 < $1 }
    }
   
    @State var isPresentedEditAlert: Bool = false
    
    @State var searchText: String = ""
    @State var members: [String] = []
    
    var body: some View {
        VStack {
//            Text("총 인원 \(keys.count)명")
            
            List {
                ForEach(members, id: \.self) { key in
                    AttendanceMasterDetailRow(isPresentedEditAlert: $isPresentedEditAlert,
                                        attendance: attendanceStore
                        .scheduleIDAndAttendanceDictionary[key,
                                                           default: .defaultModel])
                    
                }
            }
            
            // 광고 부분입니다.
            GoogleAdView()
                .frame(width: UIScreen.main.bounds.width,
                       height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(date.toStringUntilDay())")
        }
        .toast(isPresenting: $isPresentedEditAlert) {
            AlertToast(displayMode: .alert, type: .complete(.green), title: "변경 완료!")
        }
        .task {
            await attendanceStore.fetchAttendances(scheduleID: scheduleID)
            // fetch 후에 members를 불러와야 합니다.
            members = Array(
                attendanceStore
                .scheduleIDAndAttendanceDictionary
                .keys
            )
            .sorted { $0 < $1 }
        }
        
        .onDisappear {
            attendanceStore.scheduleIDAndAttendanceDictionary = [:]
        }
        .refreshable {
            await attendanceStore.fetchAttendances(scheduleID: scheduleID)
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "검색어를 입력하세요"
        )
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                members = keys
            } else {
                members = keys.filter({ key in
                    let studentCode = attendanceStore
                        .scheduleIDAndAttendanceDictionary[key,
                                                           default: .defaultModel]
                        .studentCode
                    
                    let member = memberStore
                        .studentCodeAndMemberDictionary[studentCode,
                                                        default: .defaultModel]
                    
                    return member.name.contains(newValue)
                })
            }
        })
        
    }
}

//MARK: - View(AttendanceDetailRow)
struct AttendanceMasterDetailRow: View {
    @Environment(\.dismiss) var dismiss
    
    
    let attendanceStatusList: [AttendanceStatus] = [.attendance, .late, .absent, .cancledByWeather, .cancledByCoach, .officialAbsent, .rest]
    
    @EnvironmentObject var memberStore: MemberMasterStore
    @EnvironmentObject var attendanceMasterStore: AttendanceMasterStore
    
    @State var isEditingMode: Bool = false
    @Binding var isPresentedEditAlert: Bool
    @State var pickedAttendanceStatus: AttendanceStatus = .attendance
    @State var changedLateCost: String = ""
    
    @State var attendance: Attendance
    var body: some View {
        
            HStack {
                Text("\(memberStore.studentCodeAndMemberDictionary[attendance.studentCode]?.name ?? "N/A") (\(attendance.studentCode))")
                
                Spacer()
            
                attendanceStatusView
                
                
                
            } // - HStack
        
        .swipeActions {
            Button(action: {
                isEditingMode = true
            })
            { Image(systemName: "square.and.pencil") }
            .tint(.orange)
        }
        .sheet(isPresented: $isEditingMode) {
            if #available(iOS 16, *) {
                changeAttendanceStatusSheet
                .presentationDetents([.medium])
                
            } else {
                changeAttendanceStatusSheet
            }
        }
        
        
    }
    
    //MARK: - View(attendanceStatusView)
    private var attendanceStatusView: some View {
        VStack {
            Text("\(attendance.attendanceStatus.rawValue)")
                .foregroundColor(AttendanceStatusComponentSetting(attendanceStatus: attendance.attendanceStatus).color)
            
        }
    } // - attendanceStatusView
    
    //MARK: - View(changeAttendanceStatusSheet)
    private var changeAttendanceStatusSheet: some View {
        VStack {
            Picker("", selection: $pickedAttendanceStatus) {
                ForEach(attendanceStatusList, id: \.self) { status in
                    Text(status.rawValue)
                }
            }
            .pickerStyle(.wheel)
            
            if pickedAttendanceStatus == .late {
                CustomTextField(style: .plain,
                                title: "지각한 시간",
                                text: $changedLateCost)
                    .customTextField
            }
            
            CustomButton(style: .change) {
                attendance.attendanceStatus = pickedAttendanceStatus
                attendance.lateTime = Int(changedLateCost) ?? 0
                attendanceMasterStore.updateAttendance(attendance: attendance)
                isEditingMode = false
                
                isPresentedEditAlert = true
            }.customButton
        } // - VStack
    } // - changeAttendanceStatusSheet
} // - AttendanceDetailRow
