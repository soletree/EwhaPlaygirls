//
//  EditScheduleView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/04/22.
//

import SwiftUI
import AlertToast
import CoreLocation


struct EditScheduleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var scheduleStore: ScheduleMasterStore
    
    @Binding var schedule: Schedule
    @Binding var isEditingMode: Bool
    
    @State var isProcessing = false
    
    @State var isPresentedPickerMapView: Bool = false
    @State var isPresentedDeleteScheduleAlert: Bool = false
    @State var isPresentedDeleteSchedultToastAlert: Bool = false
    @State var editedCoordinate: [Double] = []
    @State var editedAddress: String?
    
    var coordinate: Binding<CLLocationCoordinate2D> {
        Binding(
            get: {
                if editedCoordinate.isEmpty {
                    return CLLocationCoordinate2D(latitude: schedule.latitude, longitude: schedule.longitude)
                }
                return CLLocationCoordinate2D(latitude: editedCoordinate[0], longitude: editedCoordinate[1])
            },
            set: { newCoordinate in
                editedCoordinate = [newCoordinate.latitude, newCoordinate.longitude]
            }
        )
    }

    
    @State var deleteScheduleToastAlert: AlertToast = .init(displayMode: .alert, type: .complete(.green))
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(schedule.date.toStringUntilDay())")
                .font(.title.bold())
            Text("\(schedule.date.toStringOnlyHourAndMinute())")
                .bold()
            
            // 주소 변경하기 버튼
            Button(action: {isPresentedPickerMapView = true}) {
                SearchAddressBar()
            }
            .padding(10)
            
            VStack(alignment: .center) {
                CustomTextField(style: .plain,
                                title: "장소 이름을 입력해주세요.",
                                text: $schedule.address)
                .customTextField
                
                CustomTextField(style: .plain,
                                title: "상세 장소 이름을 입력해주세요.",
                                text: $schedule.detailedAddress)
                .customTextField
                
            }
            
            
            // 좌표에 맞는 위치 맵뷰 띄우기
            // MapView
            
            ScheduleMapDetailMasterView(center: coordinate)
            .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
              
            
            Spacer()
                
            .toolbar {
                // 삭제하기 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // 진짜로 삭제하는지 확인하는 알럿 띄우기
                        isPresentedDeleteScheduleAlert = true
                    }) {
                        Image(systemName: "trash.fill")
                    }
                }
                
                // 수정하기 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // 변경사항을 반영합니다.
                        isProcessing = true
                        if !editedCoordinate.isEmpty {
                            schedule.latitude = editedCoordinate[0]
                            schedule.longitude = editedCoordinate[1]
                        }
                        
                        Task {
                            let updateResult =  await scheduleStore.updateSchedule(schedule: schedule)
                            if !updateResult {
                                deleteScheduleToastAlert.type = .error(.red)
                                deleteScheduleToastAlert.title = "오류가 발생했습니다. 다시 시도하세요."
                            }
                            deleteScheduleToastAlert.type = .complete(.green)
                            deleteScheduleToastAlert.title = "업데이트 완료!"
                            
                            await scheduleStore.fetchSchedules()
                            
                            // edit mode를 종료합니다.
                            isProcessing = false
                            isPresentedDeleteSchedultToastAlert = true
                            
                            isEditingMode = false
                            
                            
                        }
                    }) {
                        Text("Done")
                    }
                } // - ToolbarItem
            } // - toolbar
            
        
            
        } // - VStack
        .disabled(isProcessing)
        .sheet(isPresented: $isPresentedPickerMapView) {
            PickAddressWithMapView(coordinateList: $editedCoordinate, isPresented: $isPresentedPickerMapView, address: $editedAddress)
        }
        // alert
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .toast(isPresenting: $isPresentedDeleteSchedultToastAlert) {
            deleteScheduleToastAlert
        }
        .alert("정말로 삭제하시겠어요?", isPresented: $isPresentedDeleteScheduleAlert) {
            Button(role: .cancel, action: {}) {
                Text("취소")
            }
            
                Button(role: .destructive, action: {
                    // 일정 삭제
                    isProcessing = true
                    Task {
                        guard await scheduleStore.deleteSchedule(scheduleID: schedule.id)
                        else {
                            isProcessing = false
                            deleteScheduleToastAlert.type = .error(.red)
                            deleteScheduleToastAlert.title = "오류가 발생했습니다. 다시 시도하세요."
                            isPresentedDeleteSchedultToastAlert = true
                            return
                        }
                        
                        // fetch가 되었는지 안 되었는지는 이 메서드에서 중요하지 않으므로 성공 여부에 따른 분기처리를 하지 않았습니다.
                        // fetch가 되면서 삭제된 schedule로 인해 자동으로 navigationView에서 빠져나오는 것으로 보입니다.
                        await scheduleStore.fetchSchedules()
                        
                        isProcessing = false
                        deleteScheduleToastAlert.type = .complete(.green)
                        deleteScheduleToastAlert.title = "삭제되었습니다."
                        isPresentedDeleteSchedultToastAlert = true
                        // navigation view 빠져나오기
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            dismiss()
                        }
                        
                    }
                    
                }) {
                    Text("삭제하기")
                }
            
            
                
        } // - alert
        
    }
}

