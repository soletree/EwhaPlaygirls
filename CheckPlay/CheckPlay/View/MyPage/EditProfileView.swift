//
//  EditProfileView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/17.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userStore: UserStore
    
    @State var isAlertUnregistreUser: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            sectionOfEditPassword
            sectionOfDeleteUser
            Spacer()
                .navigationTitle("회원정보 변경")
                .navigationBarTitleDisplayMode(.large)
        }
        .foregroundColor(.black)
        .padding(10)
        .alert("정말로 탈퇴하시겠어요?\n 탈퇴 즉시 모든 정보가 삭제됩니다.", isPresented: $isAlertUnregistreUser) {
            Button(role: .cancel, action: {}) {
                Text("취소")
            }
            Button(role: .destructive, action: {
                // unregister user
            }) {
                Text("탈퇴하기")
            }
        }
    }
    
    //MARK: - View(sectionOfEditPassword)
    private var sectionOfEditPassword: some View {
        VStack(alignment: .leading) {
            
            NavigationLink(destination: EditPasswordView().environmentObject(userStore)) {
                Text("비밀번호 변경")
            }
            Divider()
        }
    } // - sectionOfEditPassword
    
    //MARK: - View(sectionOfDeleteUser)
    private var sectionOfDeleteUser: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isAlertUnregistreUser = true
            }) {
                Text("회원탈퇴")
            }
        }
    } // - sectionOfEditPassword
}
