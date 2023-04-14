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
            Spacer()
            
            
            CustomTextField(style: .secure, title: "비밀번호를 입력해주세요", text: $userPassword).customTextField
            CustomTextField(style: .secure, title: "비밀번호를 한 번 더 입력해주세요", text: $userConfirmPassword).customTextField
            
            
            if userPassword.isEmpty && userConfirmPassword.isEmpty {
                Text(" ")
            }
            else if !isValidPassword {
                Text("사용할 수 없는 비밀번호 형식입니다!")
                    .foregroundColor(.red)
            } else if !isEqualPasswordAndConfirmPassword {
                Text("동일한 비밀번호를 입력해주세요!")
                    .foregroundColor(.red)
            } else {
                Text("사용할 수 있는 비밀번호입니다.")
                    .foregroundColor(.green)
            }
            
            
            
            CustomButton(style: .plain, action: {
                // signUp logic
                isProcessingSignUp = true
                Task {
                    let result = await userStore.signUp(email: signUpInfo.email, password: userPassword, name: signUpInfo.name, studentCode: signUpInfo.studentCode)
                    
                    if !result {
                        alertOfTypePasswordView = Alert(title: Text("회원가입에 실패했어요. 다시 시도해주세요."))
                    }
                    else {
                        alertOfTypePasswordView = Alert(title: Text("회원가입이 완료되었습니다!"), dismissButton: .cancel(Text("확인"), action: {dismiss()}))
                    }
                    
                    
                    isPresentedTypePasswordAlert = true
                    isProcessingSignUp = false
//                    // FIXME: toastAlert이 뜨고 난 후에 dismiss 시키기 위해 해둔 처리이긴 한데, 약간 부자연스러운 부분이 있음
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//                        if result {
//                            dismiss()
//                        }
//                    }
                }
            }).customButton
                .disable(isProcessingSignUp ||
                         !isValidPassword || !isEqualPasswordAndConfirmPassword)
                
                .padding(20)
            
            Spacer()
        } // - VStack
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
                .font(.largeTitle.bold())
            Text("영어 알파벳(a-Z), 숫자(0...9), 특수문자(?=.*[!@#$%^&*()_+=-]) 각각 한 글자 이상 포함, 총 6글자 이상 입력해주세요.")
                .foregroundColor(.gray)
        }
        .frame(width: UIScreen.screenWidth)
    } // - header
    
}


