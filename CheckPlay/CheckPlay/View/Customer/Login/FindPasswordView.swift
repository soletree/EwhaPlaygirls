//
//  FindPasswordView.swift
//  CheckPlay
//
//  Created by sole on 4/4/24.
//

import SwiftUI
import AlertToast

struct FindPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    @State var email: String = ""
    @StateObject var toast: AlertViewModel = .init()
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("비밀번호 찾기")
                .pretendard(size: .xxl,
                            weight: .semibold)
            
            Spacer()
            
            EPTextField(style: .email,
                        title: "가입했던 이메일을 입력해주세요.",
                        text: $email)
            
            EPButton {
                findPassword()
            } label: {
                Text("확인하기")
                    .frame(maxWidth: .infinity)
            }
            .disable(email.isEmpty ||
                     !email.isValidEmailFormat())
            
            Spacer()
        }
        .disabled(toast.isProcessing)
        .padding(.horizontal, 24)
        .toast(isPresenting: $toast.isProcessing) {
            toast.loadingAlert
        }
        .toast(isPresenting: $toast.isError) {
            toast.errorAlert
        }
        .toast(isPresenting: $toast.isComplete) {
            toast.completAlert
        }
    }
    
    //MARK: - findPassword
    
    func findPassword() {
        Task {
            toast.isProcessing = true
            do {
                try await userStore.findPassword(email: email)
                toast.setCompleteTitle(title: "\(email)", subTitle: "로 이메일 전송을 완료했어요!")
                toast.isProcessing = false
                toast.isComplete = true
            } catch {
                toast.setErrorTitle(title: "등록되지 않은 이메일이에요")
                toast.isProcessing = false
                toast.isError = true
                print("\(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    FindPasswordView()
}
