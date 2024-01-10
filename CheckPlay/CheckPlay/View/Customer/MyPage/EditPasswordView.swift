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
    var body: some View {
        VStack {
            
//             (style: .secure, title: "비밀번호를 입력하세요", text: $password). 
//             (style: .secure, title: "한 번 더 입력하세요.", text: $confirmPassword). 
            
//            CustomButton(style: .plain) {
//                if password != confirmPassword {
//                    return
//                }
//                // update password
//                Task {
//                    let result = await userStore.updatePassword(updatedPassword: password)
//                    
//                    if result { dismiss() }
//                }
//            }.customButton
//                .navigationTitle("비밀번호 변경")
//                .navigationBarTitleDisplayMode(.large)
        } // - VStack
    }
}





