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
            TextField("Type your email address", text: $userEmail)
            SecureField("Type your password", text: $userPassword)
            
            Button(action: {
                Task {
                   let isLoginSuccess = await userStore.logIn(email: userEmail, password: userPassword)
                    if !isLoginSuccess {
                        isPresentedLoginFailureAlert = true
                    }
                }
            }) {
                Text("Submit")
            }
            .buttonStyle(.borderedProminent)
            
            NavigationLink(destination: SignUpView().environmentObject(userStore)) {
                Text("회원가입")
            }
            
        } // - VStack
        .toast(isPresenting: $isPresentedLoginFailureAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "로그인에 실패했습니다! 다시 시도해주세요.")
        }
    }
}

