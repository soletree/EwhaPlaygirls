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
    
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: UIScreen.screenHeight * 0.25, height: UIScreen.screenHeight * 0.25)
                .padding(10)
            
            CustomTextField(style: .plain, title: "이메일을 입력하세요", text: $userEmail).customTextField
            CustomTextField(style: .secure, title: "비밀번호를 입력하세요", text: $userPassword).customTextField
                .padding(.bottom, 20)
            
            CustomButton(style: .login) {
                Task {
                   let isLoginSuccess = await userStore.logIn(email: userEmail, password: userPassword)
                    if !isLoginSuccess {
                        isPresentedLoginFailureAlert = true
                    }
                }
            }.customButton
            
            
            NavigationLink(destination: SignUpView().environmentObject(userStore)) {
                Text("회원가입")
                    .foregroundColor(.customLightGreen)
            }
            
        } // - VStack
        .toast(isPresenting: $isPresentedLoginFailureAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "로그인에 실패했습니다!\n 다시 시도해주세요")
        }
    }
}

