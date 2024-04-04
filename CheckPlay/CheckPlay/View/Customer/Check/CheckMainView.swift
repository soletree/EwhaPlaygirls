//
//  CheckMainView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import MapKit
import AlertToast

struct CheckMainView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var attendanceStore: AttendanceStore
    @StateObject var alertViewModel: AlertViewModel = .init()
    @ObservedObject var nfcReader = NFCReader()
    
    @State var userRegion: CLRegionState = .unknown
    
    var scheduleOfToday: Schedule? {
        scheduleStore.scheduleOfToday
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 현재 날짜
            Text("\(Date().toStringUntilDay())")
                .pretendard(size: .xl,
                            weight: .semibold)
            
            if scheduleStore.scheduleOfToday != nil {
                Text("\(scheduleOfToday!.date.toStringOnlyHourAndMinute())")
                    .pretendard(size: .s,
                                weight: .semibold)
               
            } else {
                Text("오늘은 일정이 없어요")
                    .pretendard(size: .s,
                                weight: .medium)
            }
            
            Text("출석 범위 \(userRegion.toString())이에요")
                .pretendard(size: .s,
                            weight: .medium)
            
            BeaconCheckView(userRegion: $userRegion)
            
            EPButton {
                // 오늘 일정이 있는 날인지 확인합니다.
                guard let scheduleOfToday = scheduleOfToday
                else {
                    alertViewModel.setErrorTitle(title:  AttendanceError.noSchedule.toString())
                    alertViewModel.isError = true
                    return
                }
                
                guard attendanceStore.attendanceOfToday == nil
                else { alertViewModel.setErrorTitle(title:  AttendanceError.complete.toString())
                    alertViewModel.isError = true
                    return
                }
                
                guard userRegion == .inside
                else {
                    alertViewModel.setErrorTitle(title:  AttendanceError.location.toString())
                    alertViewModel.isError = true
                    return
                }
                
                // time 조건
                guard let comparedDate = scheduleStore.scheduleOfToday?.date
                else {
                    alertViewModel.setErrorTitle(title:  AttendanceError.noSchedule.toString())
                    alertViewModel.isError = true
                    return
                }
                
                guard let timeComparedResult = Date().compareToSpecificDate(compared: comparedDate)
                else {
                    alertViewModel.setErrorTitle(title:  AttendanceError.time.toString())
                    alertViewModel.isError = true
                    return
                }
                
                let attendance = Attendance(id: UUID().uuidString,
                                            studentCode: userStore.currentUser?.studentCode ?? "",
                                            scheduleID: scheduleOfToday.id,
                                            attendanceStatus: timeComparedResult.status,
                                            lateTime: timeComparedResult.lateTime,
                                            isPaying: false,
                                            date: Date())
                
                Task {
                    // remote 변경 사항
                    guard await attendanceStore.updateAttendance(attendance: attendance)
                    else { return }
                }
                
                // local 변경 사항
                attendanceStore.attendanceOfToday = attendance
                
                // alert 처리
                alertViewModel.setCompleteTitle(title: "출석체크가 완료되었어요")
                alertViewModel.isComplete = true
            } label: {
                Text("출석하기")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 10)
            
            
            // nfc 버튼
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            nfcReader.startAlert = "핸드폰에 NFC 태그를 가까이 하세요."
                            nfcReader.read()
                            
                        }) {
                            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                        }
                    }
                }
        } // - VStack
        .padding(.horizontal, 20)
        .disabled(alertViewModel.isProcessing)
        .toast(isPresenting: $alertViewModel.isError) {
            alertViewModel.errorAlert
        }
        .toast(isPresenting: $alertViewModel.isComplete) {
            alertViewModel.completAlert
        }
        .onChange(of: nfcReader.msg) { message in
            processAttendanceWithNFC(message)
        } // - onChange

    }
    
    private func attendanceCheck() {
        
    }
    
    //MARK: - isValid
    /// 출석체크가 가능한 상태인지 확인하는 메서드입니다.
    /// - return: success 시 (출석상태, 지각한 시간), failure 시 error를 반환합니다.
    private func isValid() -> Result<(AttendanceStatus, Int), AttendanceError>{
        // nfc로 출석체크 하는 경우, 위치 체크를 하지 않습니다.
        guard let scheduleOfToday else { return .failure(.noSchedule) }
        // 오늘 일정이 있는 날인지 확인합니다.
        guard let attendanceOfToday = attendanceStore.attendanceOfToday
        else { return .failure(.noSchedule) }
        
        // 이미 출석체크가 되었으면 출석체크 과정을 수행하지 않습니다.
        if attendanceOfToday.attendanceStatus != .absent {
            return .failure(.complete)
        }
        
        // 시간 체크
        guard let timeComparedResult = Date().compareToSpecificDate(compared: scheduleOfToday.date) 
        else { return .failure(.time) }
        
        return .success(timeComparedResult)
    }
    
    //MARK: - processAttendanceWithNFC
    private func processAttendanceWithNFC(_ message: String) {
            // 적절하지 않은 nfc가 태그 됐을 때 아무 동작도 실행하지 않습니다.
            alertViewModel.isProcessing = true
            guard message == "\(Bundle.main.object(forInfoDictionaryKey: "VALID_NFC_TAG") ?? "")" else {
                // nfc msg를 초기화하기 위한 조건문입니다.
                if message == "" {
                    alertViewModel.isProcessing = false
                    return
                }
                alertViewModel.setErrorTitle(title: "잘못된 NFC 태그입니다! 다시 시도하세요.")
                alertViewModel.isProcessing = false
                alertViewModel.isError = true
                nfcReader.msg = ""
                return
            }
            
            guard let attendanceOfToday = attendanceStore.attendanceOfToday
            else {
                // 일정이 없음을 알리는 알럿
                alertViewModel.setErrorTitle(title: "오늘은 일정이 없습니다.")
                alertViewModel.isError = true
                alertViewModel.isProcessing = false
                nfcReader.msg = ""
                return
            }
            // 출석체크 로직을 수행합니다.
            switch isValid() {
            case .success(let result):
                Task {
                    // remote 출석체크
                    let updateAttendanceResult = await attendanceStore.updateAttendance(attendanceID: attendanceOfToday.id, attendanceStatus: result.0, lateTime: result.1)
                    
                    guard updateAttendanceResult else {
                        alertViewModel.setErrorTitle(title: "출석체크가 정상적으로 처리되지 않았습니다. 다시 시도해주세요!")
                        alertViewModel.isError = true
                        alertViewModel.isProcessing = false
                        return
                    }
                    // local 출석체크
                    attendanceStore.attendanceOfToday!.attendanceStatus = result.0
                    attendanceStore.attendanceOfToday!.lateTime = result.1
                    alertViewModel.setCompleteTitle(title: "출석체크가 완료되었습니다.")
                }
                
            case .failure(let error):
                switch error {
                case .time:
                    alertViewModel.setErrorTitle(title: "출석체크 시간이 아닙니다!")
                case .location:
                    alertViewModel.setErrorTitle(title: "지정된 위치가 아닙니다.")
                case .complete:
                    alertViewModel.setErrorTitle(title: "이미 출석체크가 완료되었습니다!")
                case .unknown:
                    alertViewModel.setErrorTitle(title:
                    "알 수 없는 오류입니다! 개발자에게 문의하세요.")
                case .noSchedule:
                    alertViewModel.setErrorTitle(title: "오늘은 일정이 없습니다!")
                }
            }
            nfcReader.msg = ""
            alertViewModel.isError = true
            alertViewModel.isProcessing = false
    }
}

#Preview {
    CheckMainView()
        .environmentObject(UserStore())
        .environmentObject(ScheduleStore())
        .environmentObject(AttendanceStore())
}
