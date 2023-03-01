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
    @State var isPresentedLogOutFailureToastAlert: Bool = false
    var body: some View {
        VStack {
            Text("\(userStore.currentUser?.name ?? "N/A")")
            Text("\(userStore.currentUser?.studentCode ?? "N/A")")
            
            Button(action: {}) {
                Text("회원정보 수정")
            }
            
            Button(action: {
                let logOutResult = userStore.logOut()
                if !logOutResult { isPresentedLogOutFailureToastAlert = true }
            }) {
                Text("로그아웃")
            }
            .buttonStyle(.borderedProminent)
            
           
        }
        .toast(isPresenting: $isPresentedLogOutFailureToastAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "로그아웃 실패", subTitle: "다시 시도해주세요.")
        }
    }
}

