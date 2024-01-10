//
//  ApplyView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/07.
//
import UIKit
import SwiftUI
import AlertToast

// FIXME: 웹 뷰를 통한 카페글로 이동
struct RequestView: View {
    @EnvironmentObject var scheduleStore: ScheduleStore
    
//    @State var isPresentedAddRequestSheet: Bool = false
    @State var pickedSchedule: Schedule = .defaultModel
    @State var isPresentedAddRequestAlert: Bool = false
    @State var toastAlert: AlertToast = .init(displayMode: .alert,
                                              type: .complete(.green))
    
    var body: some View {
        VStack {
            
            if scheduleStore.schedules.isEmpty {
                Spacer()
                EmptyRequestView()
            } else {
                List{
                    ForEach(scheduleStore.schedules, id: \.self.id) { schedule in
                        RequestRow(pickedSchedule: .constant(schedule),
                                   schedule: schedule,
                                   isPresentedAddRequestAlert: $isPresentedAddRequestAlert,
                                   toastAlert: $toastAlert)
                        
                    }
                    
                }
            }
            
            
            Spacer()
            
            .navigationTitle("공결 신청")
            .navigationBarTitleDisplayMode(.large)
        } // - VStack
        .task {
            await scheduleStore.fetchSchedulesUntilThreeDaysLater()
        }
        .refreshable {
            await scheduleStore.fetchSchedulesUntilThreeDaysLater()
        }
        .toast(isPresenting: $isPresentedAddRequestAlert) {
            toastAlert
        }
    }
   
}

struct RequestRow: View {
    @Binding var pickedSchedule: Schedule
    
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var requestStore: RequestStore
    var studentCode: String {
        userStore.currentUser?.studentCode ?? DefaultValue.defaultString
    }
    
    var schedule: Schedule
    
    @State var isProcessingWithFetch: Bool = false
    
    @State var isTapped: Bool = false
    
    @Binding var isPresentedAddRequestAlert: Bool
    @State var isAlreadyInRequest: Bool = false
    @State var isPresentedAddRequestSheet: Bool = false
    @Binding var toastAlert: AlertToast
    var body: some View {
            HStack {
                // fetch 중이면 ProgressView를 보여줍니다.
                if isProcessingWithFetch {
                    ProgressView()
                } else {
                    Image(systemName: isAlreadyInRequest ? "checkmark.circle.fill" : "minus.circle.fill")
                        .foregroundStyle(isAlreadyInRequest ? Color.green : Color.yellow)
                        .font(.title3)
                }
                
                VStack(alignment: .leading) {
                    Text("\(schedule.date.toStringUntilDay())")
                    Text("\(schedule.date.toStringOnlyHourAndMinute())")
                        .font(.callout)
                } // - VStack
                // detail page로 이동하는 느낌을 주기 위해 아이콘 추가
                Spacer()
                Image(systemName: "chevron.backward")
                    .rotationEffect(.init(degrees: 180))
                    .foregroundStyle(Color.gray)
                
                
                
            } // - HStack
            // HStack 내부에만 있는 컨텐츠를 탭이 가능하도록 설정합니다.
            .contentShape(Rectangle())
            .onTapGesture {
                if isProcessingWithFetch { return } // disable 처리
                isPresentedAddRequestSheet = true
                pickedSchedule = schedule
                
            }
            
            .sheet(isPresented: $isPresentedAddRequestSheet) {
                if #available(iOS 16.0, *) {
                    RequestDetailView(pickedSchedule: $pickedSchedule,
                                      isPresentedAddRequestAlert: $isPresentedAddRequestAlert,
                                      isAlreadyInRequest: $isAlreadyInRequest,
                                      toastAlert: $toastAlert)
                        .presentationDetents(isAlreadyInRequest ? [.fraction(0.45)] : [.medium])
                        .presentationDragIndicator(.visible)
                        
                } else {
                    RequestDetailView(pickedSchedule: $pickedSchedule,
                                      isPresentedAddRequestAlert: $isPresentedAddRequestAlert,
                                      isAlreadyInRequest: $isAlreadyInRequest,
                                      toastAlert: $toastAlert)
                }
                    
            }
            .task {
                isProcessingWithFetch = true
                isAlreadyInRequest = await requestStore.isAlreadyInRequest(scheduleID: pickedSchedule.id,
                                                                           studentCode: studentCode)
                isProcessingWithFetch = false
        }
        
        
    }
    
}

struct testListCell: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.secondary : Color.clear)
    }
}

//MARK: - View(RequestDetailView)
struct RequestDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var attendanceStore: AttendanceStore
    @EnvironmentObject var requestStore: RequestStore
    
    @Binding var pickedSchedule: Schedule
    
    @Binding var isPresentedAddRequestAlert: Bool
    @Binding var isAlreadyInRequest: Bool
    @State var content: String = ""
    @State var isProcessing: Bool = false
    
    @Binding var toastAlert: AlertToast
    
    var studentCode: String {
        userStore.currentUser?.studentCode ?? DefaultValue.defaultString
    }
    var body: some View {
        VStack {
            // 공결 신청이 완료되지 않은 경우
            if !isAlreadyInRequest {
                notRequest
            } else {
                alreadyRequest
            }
        } // - VStack
        
        
    }
    
    //MARK: - View(alreadyRequest)
    private var alreadyRequest: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("\(pickedSchedule.date.toStringUntilDay())")
                    .font(.title.bold())
                Text("\(pickedSchedule.date.toStringOnlyHourAndMinute())")
                Text("\(pickedSchedule.address) \(pickedSchedule.detailedAddress)")
                    .foregroundStyle(Color.gray200)
                Text("공결 신청을 완료했습니다.")
                    .bold()
            }
            .padding(10)
            .padding(.bottom, 15)
            
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.green)
                    .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenWidth * 0.4)
            }
            .frame(width: UIScreen.screenWidth)
            
        } // - VStack
    } // - alreadyRequest
    
    //MARK: - View(notRequest)
    private var notRequest: some View {
        VStack {
            Text("\(pickedSchedule.date.toStringUntilDay())")
                .font(.title.bold())
        
            TextEditor(text: $content)
                .modifier(EPTextEditorModifier(title: "사유를 입력해주세요.", text: $content))
                .padding(20)
            
            
            Text("부적절한 내용 작성 시 제재받을 수 있어요.")
                .foregroundStyle(Color.gray)
                .font(.callout)
            
            EPButton {
                requestAbsent()
            } label: {
                Text("공결신청")
                    .frame(maxWidth: .infinity)
            }
            .disabled(isProcessing || content.isEmpty)
                
            
        } // - VStack
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        
    } // - notRequest
    
    func requestAbsent() {
        Task {
            isProcessing = true
            let request: Request = .init(id: "\(pickedSchedule.id)_\(studentCode)",
                                         scheduleID: pickedSchedule.id,
                                         studentCode: studentCode,
                                         content: content)
            
            let fetchResult = await attendanceStore.findAttendanceWithScheduleID(scheduleID: request.scheduleID,
                                                                                 studentCode: request.studentCode)
            
            switch fetchResult {
            case .success(let result):
                let updateResult = await attendanceStore.updateAttendance(attendanceID: result,
                                                                          attendanceStatus: .officialAbsent)
            case .failure(_):
                toastAlert.type = .error(.red)
                toastAlert.title = "신청 중 오류가 발생했습니다! 다시 시도해주세요."
                return
            }
            
            let addResult = await requestStore.addRequest(request: request)
            // 에러 처리
            if !addResult {
                toastAlert.type = .error(.red)
                toastAlert.title = "신청 중 오류가 발생했습니다! 다시 시도해주세요."
                
                isProcessing = false
                isPresentedAddRequestAlert = true
                return
            }
            
            toastAlert.type = .complete(.green)
            toastAlert.title = "신청되었습니다!"
            
            isProcessing = false
            isPresentedAddRequestAlert = true
            dismiss()
        }
    }
}

#Preview {
    RequestView()
        .environmentObject(ScheduleStore())
}
