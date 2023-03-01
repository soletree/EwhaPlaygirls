//
//  LoginRouteView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/02.
//

import SwiftUI

/// 로그인 상태에 따라 보여지는 뷰를 분기처리합니다.
struct LoginRouteView: View {
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        if userStore.isLogin {
            ContentView()
        } else {
            LoginView()
        }
        
    }
}

