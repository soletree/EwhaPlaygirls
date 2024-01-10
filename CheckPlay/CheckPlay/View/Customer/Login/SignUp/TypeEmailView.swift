//
//  TypeEmailView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/21.
//

import SwiftUI
import AlertToast

struct TypeEmailView: View {
    @EnvironmentObject var userStore: UserStore
    
    @Binding var isTypedEmail: Bool
    @Binding var signUpInfo: SignUpInfo
    
    @State var userEmail: String = ""
    
    @State var isPresentedTypeEmailAlert: Bool = false
    var isValidEmail: Bool {
        userEmail.isValidEmailFormat()
    }
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("이메일 입력")
                .font(.largeTitle.bold())
            Text("이메일을 작성해주세요 (ex.abcd@gmail.com)")
                .foregroundStyle(Color.gray)
            

            if !userEmail.isEmpty && !isValidEmail {
                Text("유효하지 않은 이메일 형식입니다")
                    .foregroundStyle(Color.red)
            } else {
                Text(" ")
            }
            
            
            VStack(alignment: .center) {
                 EPTextField(style: .email,
                                title: "이메일을 입력해주세요",
                                text: $userEmail)
                
                EPButton {
                    validateEmail()
                } label: {
                    Text("다음으로")
                }
                .disabled(!isValidEmail)
            }
            
            Spacer()
        } // - VStack
        .padding(.horizontal, 20)
        .toast(isPresenting: $isPresentedTypeEmailAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "이미 가입된 이메일입니다! 다시 시도해주세요.")
        }
    }
    
    func validateEmail() {
        Task {
            let result = await userStore.isValidEmail(email: userEmail)
            if !result {
                isPresentedTypeEmailAlert = true
                return
            }
            signUpInfo.email = userEmail
            isTypedEmail = true
        }
    }
}

