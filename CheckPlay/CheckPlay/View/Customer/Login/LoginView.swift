//
//  LoginView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import AlertToast

struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    
    @State var isPresentedLoginFailureAlert: Bool = false
    @State var isProcessingLogin: Bool = false
    
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(maxWidth: 300)
                .frame(maxHeight: 200)
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
            
            EPTextField(style: .email,
                        title: "이메일을 입력하세요",
                        text: $userEmail)
            EPTextField(style: .secure,
                        title: "비밀번호를 입력하세요",
                        text: $userPassword)
            
            
            EPButton {
                processLogin()
            } label: {
            Text("로그인")
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 20)
            .disabled(isProcessingLogin)
            
            NavigationLink(destination: SignUpRouteView().environmentObject(userStore)) {
                HStack {
                    Text("회원가입")
                        .pretendard(size: .s,
                                    weight: .regular)
                        .foregroundStyle(Color.subColor200)
                    
                    Text("|")
                        .pretendard(size: .s,
                                    weight: .regular)
                        .foregroundStyle(Color.subColor200)
                    
                    Text("비밀번호 찾기")
                        .pretendard(size: .s,
                                    weight: .regular)
                        .foregroundStyle(Color.subColor200)
                }
                
            }
        } // - VStack
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity)
        .disabled(isProcessingLogin)
        .toast(isPresenting: $isProcessingLogin) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .toast(isPresenting: $isPresentedLoginFailureAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "로그인에 실패했습니다!\n 다시 시도해주세요")
        }
    }
    
    func processLogin() {
        Task {
            isProcessingLogin = true
           let isLoginSuccess = await userStore.logIn(email: userEmail, password: userPassword)
            if !isLoginSuccess {
                isPresentedLoginFailureAlert = true
            }
            isProcessingLogin = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserStore())
}
