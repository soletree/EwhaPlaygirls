//
//  ReLogInView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/17.
//

import SwiftUI

//MARK: - View(ReLogInView)
/// 민감한 작업에 접근하기 위해 한번더 로그인을 요청하는 뷰입니다.
struct ReLogInView: View {
    @EnvironmentObject var userStore: UserStore
    @Binding var isReauthenticatedUser: Bool
    
    @State var password: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("인증하기")
                .pretendard(size: .xxl,
                            weight: .semibold)
            Text("보안에 민감한 작업 전 한 번 더 인증하는 과정이에요")
                .pretendard(size: .s,
                            weight: .medium)
                .foregroundStyle(Color.gray300)
                .padding(.bottom, 30)
            
             EPTextField(style: .secure, title: "비밀번호를 입력하세요", text: $password)
                .padding(.bottom, 10)
            
            EPButton {
                reAuthorize()
            } label: {
                Text("인증하기")
                    .frame(maxWidth: .infinity)
            }
        } // - VStack
        .padding(.horizontal, 20)
    }
    
    //MARK: - reAuthorize
    func reAuthorize() {
        Task {
            // 사용자를 재인증합니다.
            let result = await userStore.relogInAndReauthentication(password: password)
            // 재인증에 실패(로그인에 실패)
            guard result
            else { return }
            isReauthenticatedUser = true
        }
    }
} // - ReLogInView

#Preview {
    ReLogInView(isReauthenticatedUser: .constant(false),
                 password: "")
}
