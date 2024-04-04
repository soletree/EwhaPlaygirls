//
//  EditProfileView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/16.
//

import SwiftUI

//MARK: - View(EditPasswordView)
/// 비밀번호 변경 뷰입니다.
struct EditPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userStore: UserStore
    
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("비밀번호 변경")
                .pretendard(size: .xxl,
                            weight: .semibold)
            Text("기존의 비밀번호를 변경할 수 있어요")
                .pretendard(size: .s,
                            weight: .medium)
                .foregroundStyle(Color.gray300)
                .padding(.bottom, 30)
            
             EPTextField(style: .secure, title: "비밀번호를 입력하세요", text: $password)
             EPTextField(style: .secure, title: "한 번 더 입력하세요.", text: $confirmPassword)
            
            Text("\(errorMessage)")
                .foregroundStyle(Color.red)
                .padding(.bottom, 20)
            
            EPButton {
                guard password == confirmPassword
                else {
                    errorMessage = "비밀번호를 동일하게 입력해주세요!"
                    return
                }
                requestUpdatePassword()
                
                } label: {
                Text("변경하기")
                    .frame(maxWidth: .infinity)
            }

        } // - VStack
        .padding(.horizontal, 20)
        .frame(maxHeight: .infinity)
    }
    
    func requestUpdatePassword() {
        // update password
        Task {
            let result = await userStore.updatePassword(updatedPassword: password)
            
            if result { dismiss() }
        }

    }
}

#Preview {
    EditPasswordView()
}
