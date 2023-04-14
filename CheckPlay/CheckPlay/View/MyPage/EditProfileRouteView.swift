//
//  EditProfileRouteView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/17.
//

import SwiftUI

/// 민감한 작업(비밀번호 변경, 회원탈퇴)에 접근하기 위해 사용자의 인증 상태에 따라 보이는 뷰를 분기처리 하는 뷰입니다.
struct EditProfileRouteView: View {
    @EnvironmentObject var userStore: UserStore
    
    @State var isReauthenticatedUser: Bool = false
    var body: some View {
        // 인증된 사용자면 민감한 작업이 가능한 뷰로 분기처리해줍니다.
        if isReauthenticatedUser {
            EditProfileView()
        } else {
            // 인증되지 않은 사용자면 한번 더 로그인하도록 합니다.
            ReLogInView(isReauthenticatedUser: $isReauthenticatedUser)
        }
    }
}
