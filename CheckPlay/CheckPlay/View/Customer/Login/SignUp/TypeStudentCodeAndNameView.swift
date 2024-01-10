//
//  TypeStudentCodeAndNameView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/21.
//

import SwiftUI
import AlertToast

struct TypeStudentCodeAndNameView: View {
    @EnvironmentObject var userStore: UserStore
    
    @Binding var isMember: Bool
    @Binding var signUpInfo: SignUpInfo
    
    @State var userName: String = ""
    @State var userStudentCode: String = ""
    
    @State var isPresentedTypeStudentCodeAndNameViewAlert: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            Text("학생 정보 입력")
                .pretendard(size: .xxl,
                            weight: .bold)
            Text("학번 7자리(ex. 1234567)\n이름(ex. 김이화)을 입력해주세요.")
                .pretendard(size: .xs,
                            weight: .medium)
                .foregroundStyle(Color.gray200)
            

            VStack(alignment: .center) {
                EPTextField(style: .studentCode,
                            title: "학번을 입력하세요",
                            text: $userStudentCode)
                EPTextField(style: .plain,
                            title: "이름을 입력하세요",
                            text: $userName)
                
                Spacer()
                
                EPButton {
                    checkValidMember()
                } label: {
                    Text("다음으로")
                        .frame(maxWidth: .infinity)
                }
            }
        } // - VStack
        .padding(.horizontal, 20)
        .toast(isPresenting: $isPresentedTypeStudentCodeAndNameViewAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "잘못된 정보입니다. 다시 시도하세요!")
        }
    }
    
    // FIXME 학번 정규식 추가
    func checkValidMember() {
        Task {
            let result = await userStore.isValidStudentCode(name: userName, studentCode: userStudentCode)
            if !result { isPresentedTypeStudentCodeAndNameViewAlert = true
                return
            }
            signUpInfo.studentCode = userStudentCode
            signUpInfo.name = userName
            isMember = true
        }
    }
}


