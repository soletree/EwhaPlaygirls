//
//  EditProfileView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/17.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userStore: UserStore
    
    @State var isPresentedEditPasswordView: Bool = false
    @State var isAlertUnregistreUser: Bool = false
    @State var isPresentedSuccessAlertDeleteUser: Bool = false
    
    @State var alertMessage: String = "탈퇴되었습니다. \n 감사합니다."
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("회원정보 변경")
                    .pretendard(size: .xxl,
                                weight: .semibold)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.subColor300)
            
            Group {
                sectionOfEditPassword
                sectionOfDeleteUser
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .navigationDestination(isPresented: $isPresentedEditPasswordView) {
            EditPasswordView()
                .environmentObject(userStore)
        }
        .alert("정말로 탈퇴하시겠어요?\n 탈퇴 즉시 모든 정보가 삭제됩니다.",
               isPresented: $isAlertUnregistreUser) {
            Button(role: .cancel) { }
            label: {
                Text("취소")
            }
            Button(role: .destructive)  {
                // unregister user
                unregisterUser()
            } label: {
                Text("탈퇴하기")
            }
        }
        .alert(alertMessage, isPresented: $isPresentedSuccessAlertDeleteUser) {
        }
    }
    
    //MARK: - View(sectionOfEditPassword)
    private var sectionOfEditPassword: some View {
        HStack {
            Text("비밀번호 변경")
                .pretendard(size: .s,
                            weight: .regular)
            
            Spacer()
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresentedEditPasswordView = true
        }
    } // - sectionOfEditPassword
    
    //MARK: - View(sectionOfDeleteUser)
    private var sectionOfDeleteUser: some View {
        HStack {
            Text("회원탈퇴")
                .pretendard(size: .s,
                             weight: .regular)
            
            Spacer()
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            isAlertUnregistreUser = true
        }
    } // - sectionOfEditPassword
    
    //MARK: - unregisterUser
    func unregisterUser() {
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
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserStore())
}
