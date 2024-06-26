//
//  TypePasswordView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/21.
//

import SwiftUI
import AlertToast

struct TypePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    
    @Binding var signUpInfo: SignUpInfo
    
    @State var userPassword: String = ""
    @State var userConfirmPassword: String = ""
    
    @State var isPresentedTypePasswordAlert: Bool = false
    @State var isProcessingSignUp: Bool = false
    
    @State var alertOfTypePasswordView: Alert = .init(title: Text(""))
    
    var isEqualPasswordAndConfirmPassword: Bool {
        userPassword == userConfirmPassword
    }
    
    var isValidPassword: Bool {
        userPassword.isValidPasswordFormat()
    }
    
    var body: some View {
        VStack {
            Spacer()
            headerOfTypePasswordView
            
            EPTextField(style: .secure,
                        title: "비밀번호를 입력해주세요",
                        text: $userPassword)
            EPTextField(style: .secure,
                        title: "비밀번호를 한 번 더 입력해주세요",
                        text: $userConfirmPassword)
            
            
            if userPassword.isEmpty && userConfirmPassword.isEmpty {
                Text(" ")
            }
            else if !isValidPassword {
                Text("사용할 수 없는 비밀번호 형식입니다!")
                    .foregroundStyle(Color.red)
            } else if !isEqualPasswordAndConfirmPassword {
                Text("동일한 비밀번호를 입력해주세요!")
                    .foregroundStyle(Color.red)
            } else {
                Text("사용할 수 있는 비밀번호입니다.")
                    .foregroundStyle(Color.green)
            }
            
            EPButton {
                // signUp logic
                isProcessingSignUp = true
                Task {
                    let result = await userStore.signUp(email: signUpInfo.email,
                                                        password: userPassword,
                                                        name: signUpInfo.name,
                                                        studentCode: signUpInfo.studentCode)
                    
                    if !result {
                        alertOfTypePasswordView = Alert(title: Text("회원가입에 실패했어요. 다시 시도해주세요."))
                    }
                    else {
                        alertOfTypePasswordView = Alert(title: Text("회원가입이 완료되었습니다!"), dismissButton: .cancel(Text("확인"), action: {dismiss()}))
                    }
                    isPresentedTypePasswordAlert = true
                    isProcessingSignUp = false
                }
            } label: {
                Text("다음으로")
                    .frame(maxWidth: .infinity)
            }
            .disabled(isProcessingSignUp ||
                      !isValidPassword || !isEqualPasswordAndConfirmPassword)
            
            Spacer()
        } // - VStack
        .padding(.horizontal, 20)
        .disabled(isProcessingSignUp)
        //        .toast(isPresenting: $isPresentedTypePasswordAlert) {
        //            alertOfTypePasswordView
        //        }
        .toast(isPresenting: $isProcessingSignUp) {
            AlertToast(displayMode: .alert, type: .loading)
        }
        .alert(isPresented: $isPresentedTypePasswordAlert) {
            alertOfTypePasswordView
        }
        
    }
    
    //MARK: - View(header)
    private var headerOfTypePasswordView: some View {
        VStack(alignment: .leading) {
            Text("비밀번호 설정")
                .pretendard(size: .xxl,
                            weight: .semibold)
            Text("영어 알파벳(a-Z), 숫자(0...9),\n특수문자(?=.*[!@#$%^&*()_+=-])\n각각 한 글자 이상 포함, 총 6글자 이상 입력해주세요.")
                .foregroundStyle(Color.gray)
        }
        .frame(width: UIScreen.screenWidth)
    } // - header
    
}

#Preview {
    TypePasswordView(signUpInfo: .constant(.init()))
        .environmentObject(UserStore())
}
