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
    @State var isPresentedSuccessAlertDeleteUser: Bool = false
    
    @State var alertMessage: String = "탈퇴되었습니다. \n 감사합니다."
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            sectionOfEditPassword
            sectionOfDeleteUser
            Spacer()
                .navigationTitle("회원정보 변경")
                .navigationBarTitleDisplayMode(.large)
        }
        .foregroundStyle(Color.black)
        .padding(10)
        .alert("정말로 탈퇴하시겠어요?\n 탈퇴 즉시 모든 정보가 삭제됩니다.", isPresented: $isAlertUnregistreUser) {
            Button(role: .cancel, action: {}) {
                Text("취소")
            }
            Button(role: .destructive, action: {
                // unregister user
                Task {
                    let result = await userStore.deleteUser()
                    if result {
                        alertMessage = "탈퇴되었습니다. \n 감사합니다."
                        
                    } else {
                        alertMessage = "알 수 없는 오류가 발생했습니다. 다시 시도해주세요!"
                    }
                    isPresentedSuccessAlertDeleteUser = true
                    userStore.logOut()
                }
            }) {
                Text("탈퇴하기")
            }
        }
        .alert(alertMessage, isPresented: $isPresentedSuccessAlertDeleteUser) {
        
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
