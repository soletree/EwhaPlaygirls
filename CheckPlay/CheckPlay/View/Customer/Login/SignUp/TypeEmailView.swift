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
    
    var errorMessage: String {
        isValidEmail ? "" : "유효하지 않은 이메일 형식입니다"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("이메일 입력")
                .pretendard(size: .xxl,
                            weight: .semibold)
            Text("이메일을 작성해주세요")
                .pretendard(size: .xs,
                            weight: .medium)
                .foregroundStyle(Color.gray)
            Text("예시 - abcd@gmail.com")
                .pretendard(size: .xs,
                            weight: .medium)
                .foregroundStyle(Color.gray)
            
            
            VStack(alignment: .leading) {
                 EPTextField(style: .email,
                                title: "이메일을 입력해주세요",
                                text: $userEmail)
                
                Text("\(errorMessage)")
                    .pretendard(size: .xs,
                                weight: .medium)
                    .foregroundStyle(Color.red)
                    .padding(.bottom, 10)
                
                EPButton {
                    validateEmail()
                } label: {
                    Text("다음으로")
                        .frame(maxWidth: .infinity)
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
    
    //MARK: - validateEmail
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

#Preview {
    TypeEmailView(isTypedEmail: .constant(false),
                  signUpInfo: .constant(.init()))
        .environmentObject(UserStore())
}
