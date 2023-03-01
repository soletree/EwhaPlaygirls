//
//  SignUpView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/28.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var userName: String = ""
    @State var userStudentCode: String = ""
    
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    @State var isPresentedSignUpAlert: Bool = false
    
    @State var isValidEmail: Bool = false
    @State var isPresentedVerifyEmailMessage: Bool = false
    var verifyEmailMessage: String {
        isValidEmail ?
        "사용 가능한 이메일입니다." : "사용할 수 없는 이메일입니다."
    }
    
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            TextField("Type your name", text: $userName)
            TextField("Type your studentCode", text: $userStudentCode)
            
            
            
            HStack {
                TextField("Type your email", text: $userEmail)
                Button(action: {
                    Task {
                        // 유효한 이메일인지 검증합니다.
                        isValidEmail = await !userStore.isValidEmail(email: userEmail)
                        isPresentedVerifyEmailMessage = true
                    }
                }) {
                    Text("Verify")
                }
            }
            
            if isPresentedVerifyEmailMessage {
                Text("\(verifyEmailMessage)")
                    .foregroundColor(isValidEmail ? .green : .red)
            }
            
            SecureField("Type your password", text: $userPassword)
            Button(action: {
                Task {
                    let signUpResult = await userStore.signUp(email: userEmail ,   password: userPassword, name: userName, studentCode: userStudentCode)
                    switch signUpResult {
                    case .success(_):
                        print("회원가입 성공")
                        dismiss()
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    
                    }
                }
            }) {
                Text("Submit")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValidEmail)
        }
    }
}


