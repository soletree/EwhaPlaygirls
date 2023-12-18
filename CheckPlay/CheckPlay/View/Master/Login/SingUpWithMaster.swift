//
//  SingUpWithMaster.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import SwiftUI
import AlertToast

struct SingUpWithMaster: View {
    @State var masterID: String = ""
    @State var masterPassword: String = ""
    
    @State var isProcessing: Bool = false
    @State var isPresentedMasterMainView: Bool = false
    @State var isPresentedLoginErrorAlert: Bool = false
    
    @EnvironmentObject var userStore: UserStore
    
    @StateObject var memberStore: MemberMasterStore = .init()
    @StateObject var scheduleStore: ScheduleMasterStore = .init()
    @StateObject var attendanceStore: AttendanceMasterStore = .init()
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("관리자 모드 전환하기")
                .font(.largeTitle.bold())
            
            Text("관리자용 아이디와\n비밀번호를 입력해주세요.")
                .foregroundColor(.customGray)
                .padding(.bottom, 20)
            
            CustomTextField(style: .plain,
                            title: "아이디를 입력해주세요",
                            text: $masterID)
                            .customTextField
            CustomTextField(style: .secure,
                            title: "비밀번호를 입력해주세요",
                            text: $masterPassword)
                            .customTextField
                            .padding(.bottom, 20)
            
            
            CustomButton(style: .plain){
                Task {
                    isProcessing = true
                    let result = await AdminStore.login(id: masterID, password: masterPassword)
                    
                    isProcessing = false
                    if result {
                        userStore.isPresentedAdmin = true
                    } else {
                        isPresentedLoginErrorAlert = true
                    }
                    
                }
            }.customButton
                .padding(.bottom, 10)
                .disabled(isProcessing)
            
        }
        .disabled(isProcessing)
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert,
                       type: .loading)
        }
        .toast(isPresenting: $isPresentedLoginErrorAlert) {
            AlertToast(displayMode: .alert,
                       type: .error(.red),
                       title: "잘못된 아이디 또는 비밀번호입니다!")
        }
        
        
    }
    
}
