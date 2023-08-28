//
//  AddScheduleView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/04.
//

import SwiftUI
import CoreLocation
import AlertToast

struct AddScheduleView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var scheduleStore: ScheduleMasterStore
    @EnvironmentObject var attendanceStore: AttendanceMasterStore
    @EnvironmentObject var memberStore: MemberMasterStore
    
    @Binding var isPresentedAddScheduleAlert: Bool
    
    @State var date: Date = .init()
    @State var location: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    @State var address: String = ""
    @State var detailedAddress: String = ""
    
    @State var isPresentedPickAddressView: Bool = false
    @State var coordinates: [Double] = []
    @State var addressForMap: String? = ""
    
    
    @State var isProcessing: Bool = false
    var body: some View {
        VStack {
            
            Button(action: {
                isPresentedPickAddressView = true
            }) {
                SearchAddressBar()
            }
            ScheduleMapDetailMasterView(center: $location)
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
            
            // map picker
            
            CustomTextField(style: .plain, title: "주소를 입력하세요.", text: $address).customTextField
            CustomTextField(style: .plain, title: "상세 주소를 입력하세요.", text: $detailedAddress).customTextField
            
            
            DatePickerView(date: $date)
            
            
            
            CustomButton(style: .plain, action: {
                isProcessing = true
                if coordinates.isEmpty {
                    isProcessing = false
                    return
                }
                let newSchedule = Schedule(id: UUID().uuidString,
                                           date: date,
                                           latitude: coordinates[0],
                                           longitude: coordinates[1],
                                           address: address,
                                           detailedAddress: detailedAddress)
                
                Task {
                    await scheduleStore.addSchedule(schedule: newSchedule)
                    await attendanceStore.addAttendance(scheduleID: newSchedule.id,
                                                        date: newSchedule.date,
                                                        memberStore: memberStore)
                    
                    isPresentedAddScheduleAlert = true
                    isProcessing = false
                    dismiss()
                }
            }).customButton
                .disable(coordinates.isEmpty || isProcessing)
            
        } // - VStack
        .onChange(of: coordinates) { newValue in
            if coordinates.isEmpty {
                return
            }
            location.latitude = coordinates[0]
            location.longitude = coordinates[1]
        }
        .disabled(isProcessing)
        .sheet(isPresented: $isPresentedPickAddressView) {
            PickAddressWithMapView(coordinateList: $coordinates, isPresented: $isPresentedPickAddressView, address: $addressForMap)
        }
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

struct SearchAddressBar: View {
    var body: some View {
        Capsule()
            .stroke(Color.customGray, lineWidth: 2)
            .frame(width: UIScreen.screenWidth * 0.8,
                   height: UIScreen.screenHeight * 0.06)
            .overlay {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("주소 검색하기")
                        .font(.headline)
                    Spacer()
                }
                .padding(10)
                .foregroundColor(.customGray)
            }
        
        
    }
}
