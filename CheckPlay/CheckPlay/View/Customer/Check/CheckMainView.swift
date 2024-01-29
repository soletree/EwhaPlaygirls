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
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37, longitude: 128), latitudinalMeters: 500, longitudinalMeters: 500)
    @ObservedObject var nfcReader = NFCReader()
    
    @State var isPresentedNFCAlert: Bool = false
    @State var isProcessingWithNFC: Bool = false
    @State var alertOfNFC = AlertToast(displayMode: .alert, type: .regular)
    
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
                .pretendard(size: .xl,
                            weight: .semibold)
            
            if scheduleStore.scheduleOfToday != nil {
                Group {
                    Text("\(scheduleOfToday!.date.toStringOnlyHourAndMinute())")
                        .pretendard(size: .s,
                                    weight: .semibold)
                    Text("\(scheduleOfToday!.address) \(scheduleOfToday!.detailedAddress)")
                        .pretendard(size: .s,
                                    weight: .semibold)
                } // - VStack
            } else {
                Text("오늘은 일정이 없습니다.")
                    .pretendard(size: .s,
                                weight: .regular)
            }
                
            
            // 지도
            CheckMapView(circleCenter: circleCenter)
                .overlay {
                    if isProcessingWithNFC {
                        ProgressView()
                    }
                }
            
            
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
        .disabled(isProcessingWithNFC)
        .toast(isPresenting: $isPresentedNFCAlert) {
            alertOfNFC
        }
        .onChange(of: nfcReader.msg) { message in
            processAttendanceWithNFC(message)
        } // - onChange

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
        guard let timeComparedResult = Date().compareToSpecificDate(compared: scheduleOfToday.date) else { return .failure(.time) }
        
        return .success(timeComparedResult)
    }
    
    //MARK: - processAttendanceWithNFC
    private func processAttendanceWithNFC(_ message: String) {
            // 적절하지 않은 nfc가 태그 됐을 때 아무 동작도 실행하지 않습니다.
            isProcessingWithNFC = true
            guard message == "\(Bundle.main.object(forInfoDictionaryKey: "VALID_NFC_TAG") ?? "")" else {
                // nfc msg를 초기화하기 위한 조건문입니다.
                if message == "" {
                    isProcessingWithNFC = false
                    return
                }
                alertOfNFC.title = "잘못된 NFC 태그입니다! 다시 시도하세요."
                isPresentedNFCAlert = true
                isProcessingWithNFC = false
                nfcReader.msg = ""
                return
            }
            
            guard let attendanceOfToday = attendanceStore.attendanceOfToday
            else {
                // 일정이 없음을 알리는 알럿
                
                alertOfNFC.title = "오늘은 일정이 없습니다."
                isPresentedNFCAlert = true
                isProcessingWithNFC = false
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
                        alertOfNFC.title = "출석체크가 정상적으로 처리되지 않았습니다. 다시 시도해주세요!"
                        isPresentedNFCAlert = true
                        isProcessingWithNFC = false
                        return
                    }
                    // local 출석체크
                    attendanceStore.attendanceOfToday!.attendanceStatus = result.0
                    attendanceStore.attendanceOfToday!.lateTime = result.1
                    alertOfNFC.type = .complete(.green)
                    alertOfNFC.title = "출석체크가 완료되었습니다."
                }
                
            case .failure(let error):
                switch error {
                case .time:
                    alertOfNFC.title = "출석체크 시간이 아닙니다!"
                case .location:
                    alertOfNFC.title = "지정된 위치가 아닙니다."
                case .complete:
                    alertOfNFC.title = "이미 출석체크가 완료되었습니다!"
                case .unknown:
                    alertOfNFC.title = "알 수 없는 오류입니다! 개발자에게 문의하세요."
                case .noSchedule:
                    alertOfNFC.title = "오늘은 일정이 없습니다!"
                }
            }
            nfcReader.msg = ""
            isPresentedNFCAlert = true
            isProcessingWithNFC = false
    }
}

#Preview {
    CheckMainView()
        .environmentObject(UserStore())
        .environmentObject(ScheduleStore())
        .environmentObject(AttendanceStore())
}
