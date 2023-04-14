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
            Spacer()
            Text("학번, 이름 작성")
                .font(.largeTitle.bold())
            Text("학번 7자리(ex. 1234567)\n이름(ex. 김감자)을 입력해주세요.")
                .foregroundColor(.gray)
            
            
            Spacer()
            VStack(alignment: .center) {
                CustomTextField(style: .studentCode, title: "학번을 입력하세요", text: $userStudentCode).customTextField
                CustomTextField(style: .plain, title: "이름을 입력하세요", text: $userName).customTextField
                
                
                CustomButton(style: .plain, action: {
                    Task {
                        let result = await userStore.isValidStudentCode(name: userName, studentCode: userStudentCode)
                        if !result { isPresentedTypeStudentCodeAndNameViewAlert = true
                            return
                        }
                        print("등록된 멤버 정보")
                        signUpInfo.studentCode = userStudentCode
                        signUpInfo.name = userName
                        isMember = true
                    }
                }).customButton
                    .padding(20)
            }
            
            Spacer()
            
        } // - VStack
        .toast(isPresenting: $isPresentedTypeStudentCodeAndNameViewAlert) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "잘못된 정보입니다. 다시 시도하세요!")
        }
    }
    
    //MARK: - View(header)
    private var headerOfTypeStudentCodeAndName: some View {
        VStack(alignment: .leading) {
            Text("학번, 이름 작성")
                .font(.largeTitle.bold())
            Text("학번 7자리(ex. 1234567)\n 이름(ex. 김감자)을 입력해주세요.")
                .foregroundColor(.gray)
        }
        .frame(minWidth: UIScreen.screenWidth)
    } // - header
}


