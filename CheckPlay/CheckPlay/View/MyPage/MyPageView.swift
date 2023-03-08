//
//  MyPageView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import AlertToast

struct MyPageView: View {
    @EnvironmentObject var userStore: UserStore
    @State var isProcessing: Bool = false
    @State var isPresentedLogOutFailureToastAlert: Bool = false
    @State var toastAlertWithLogOut: AlertToast = .init(displayMode: .alert, type: .error(.red))
    var body: some View {
        VStack {
            Text("\(userStore.currentUser?.name ?? "N/A")")
            Text("\(userStore.currentUser?.studentCode ?? "N/A")")
            
            Button(action: {}) {
                Text("회원정보 수정")
            }
            CustomButton(style: .logout, action: {
                isProcessing = true
                let logOutResult = userStore.logOut()
                isProcessing = false
                // 로그아웃이 실패하면 알럿을 띄워줍니다.
                if !logOutResult {
                    toastAlertWithLogOut.title = "로그아웃 실패"
                    toastAlertWithLogOut.subTitle = "다시 시도해주세요."
                    toastAlertWithLogOut.type = .error(.red)
                } else {
                    toastAlertWithLogOut.title = "로그아웃되었습니다."
                    toastAlertWithLogOut.type = .complete(.green)
                }
                isPresentedLogOutFailureToastAlert = true
            }).customButton
            
           
        }
        .toast(isPresenting: $isPresentedLogOutFailureToastAlert) {
            toastAlertWithLogOut
        }
        .toast(isPresenting: $isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}

