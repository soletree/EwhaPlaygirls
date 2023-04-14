//
//  LoginView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI
import AlertToast

struct LoginView: View {
    @State var isPresentedLoginFailureAlert: Bool = false
    @State var isProcessingLogin: Bool = false
    
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.15)
                .padding(10)
            
            CustomTextField(style: .email, title: "이메일을 입력하세요", text: $userEmail).customTextField
            CustomTextField(style: .secure, title: "비밀번호를 입력하세요", text: $userPassword).customTextField
                .padding(.bottom, 20)
            
            CustomButton(style: .login) {
                Task {
                    isProcessingLogin = true
                   let isLoginSuccess = await userStore.logIn(email: userEmail, password: userPassword)
                    if !isLoginSuccess {
                        isPresentedLoginFailureAlert = true
                    }
                    isProcessingLogin = false
                }
            }.customButton
                .disable(isProcessingLogin)
            
            
            NavigationLink(destination: SignUpRouteView().environmentObject(userStore)) {
                Text("회원가입")
                    .foregroundColor(.customLightGreen)
            }
            
        } // - VStack
        .disabled(isProcessingLogin)
        .toast(isPresenting: $isProcessingLogin) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .toast(isPresenting: $isPresentedLoginFailureAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "로그인에 실패했습니다!\n 다시 시도해주세요")
        }
        
    }
}

