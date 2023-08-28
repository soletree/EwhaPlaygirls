//
//  ReLogInView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/17.
//

import SwiftUI

//MARK: - View(ReLogInView)
/// 민감한 작업에 접근하기 위해 한번더 로그인을 요청하는 뷰입니다.
struct ReLogInView: View {
    @EnvironmentObject var userStore: UserStore
    @Binding var isReauthenticatedUser: Bool
    
    @State var password: String = ""
    
    var body: some View {
        VStack {
            CustomTextField(style: .secure, title: "비밀번호를 입력하세요", text: $password).customTextField
                .padding(.bottom, 10)
            
            CustomButton(style: .plain) {
                Task {
                    // 사용자를 재인증합니다.
                    let result = await userStore.relogInAndReauthentication(password: password)
                    // 재인증에 실패(로그인에 실패)
                    if !result { return }
                    
                    isReauthenticatedUser = true
                    
                }
                // navigate update-password-View
            }.customButton
                .navigationTitle("비밀번호 확인")
                .navigationBarTitleDisplayMode(.large)
        } // - VStack
    }
} // - ReLogInView
