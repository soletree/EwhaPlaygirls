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
                .foregroundColor(.gray)
            
            Spacer()
            if !userEmail.isEmpty && !isValidEmail {
                Text("유효하지 않은 이메일 형식입니다")
                    .foregroundColor(.red)
            } else {
                Text(" ")
            }
            
            
            VStack(alignment: .center) {
                CustomTextField(style: .email,
                                title: "이메일을 입력해주세요",
                                text: $userEmail).customTextField
                
                CustomButton(style: .plain, action: {
                    Task {
                        let result = await userStore.isValidEmail(email: userEmail)
                        if !result {
                            isPresentedTypeEmailAlert = true
                            return
                        }
                        // next phase
                        print("가능한 이메일 ")
                        signUpInfo.email = userEmail
                        isTypedEmail = true
                    }
                }).customButton
                    .disable(!isValidEmail)
                    .padding(20)
                    
            }
            
            Spacer()
        } // - VStack
        .toast(isPresenting: $isPresentedTypeEmailAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "이미 가입된 이메일입니다! 다시 시도해주세요.")
        }
    }
}

