//
//  SignUpView.swift
//  CheckPlay
//
//  Created by sole on 2023/02/28.
//

import SwiftUI
import AlertToast

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var userName: String = ""
    @State var userStudentCode: String = ""
    
    @State var userEmail: String = ""
    @State var userPassword: String = ""
    @State var confirmUserPassword: String = ""
    @State var isPresentedSignUpAlert: Bool = false
    @State var signUpErrorMessage: String = ""
    
    @State var isValidEmail: Bool = false
    @State var isPresentedVerifyEmailMessage: Bool = false
    var verifyEmailMessage: String {
        isValidEmail ?
        "사용 가능한 이메일입니다." : "사용할 수 없는 이메일입니다."
    }
    
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack {
            
            Section(header: Text("동아리 회원 확인")) {
                CustomTextField(style: .plain, title: "이름을 입력하세요", text: $userName).customTextField
                CustomTextField(style: .plain, title: "학번을 입력하세요 (ex. 1234567)", text: $userStudentCode).customTextField
            }
            
            Section(header: Text("이메일").bold()) {
                HStack {
                    CustomTextField(style: .plain, title: "이메일 주소를 입력하세요.", text: $userEmail).customTextField
                    
                    CustomButton(style: .verifyEmail) {
                        Task {
                            // 유효한 이메일인지 검증합니다.
                            isValidEmail = await !userStore.isValidEmail(email: userEmail)
                            isPresentedVerifyEmailMessage = true
                        }
                    }.customButton
                    
                } // - HStack
                
                if isPresentedVerifyEmailMessage {
                    Text("\(verifyEmailMessage)")
                        .foregroundColor(isValidEmail ? .green : .red)
                } else {
                    Text("")
                }
            }
            
            Section(header: Text("비밀번호")) {
                CustomTextField(style: .secure, title: "비밀번호를 입력하세요", text: $userPassword).customTextField
                CustomTextField(style: .secure, title: "비밀번호를 한번 더 입력하세요", text: $confirmUserPassword).customTextField
            }
            
            CustomButton(style: .signUp, action:
                            {
                Task {
                    let signUpResult = await userStore.signUp(email: userEmail,  password: userPassword, name: userName, studentCode: userStudentCode)
                    switch signUpResult {
                    case .success(_):
                        print("회원가입 성공")
                        
                        dismiss()
                    case .failure(let error):
                        switch error {
                        case .invalidEmailFormat:
                            signUpErrorMessage = "올바르지 않은 형식의 이메일입니다."
                        case .duplicatedEmail:
                            signUpErrorMessage = "중복된 이메일입니다."
                        case .invalidStudentCode:
                            signUpErrorMessage = "유효하지 않은 학번입니다."
                        case .unsafetyPassword:
                            signUpErrorMessage = "안전하지 않은 비밀번호입니다."
                        case .alreadySigned:
                            signUpErrorMessage = "이미 가입된 정보입니다."
                        case .unknown:
                            signUpErrorMessage = "알 수 없는 오류. 개발진에 문의해주세요."
                        }
                        isPresentedSignUpAlert = true
                        print("\(error.localizedDescription)")
                    }
                }
            }
            ).customButton
            .disabled(!isValidEmail)
            
            
            .navigationTitle("회원가입")
        } // - VStack
        .toast(isPresenting: $isPresentedSignUpAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: signUpErrorMessage)
        }
    }
}


