//
//  AddMemberView.swift
//  EwhaPlaygirls-admin
//
//  Created by sole on 2023/03/04.
//

import SwiftUI
import AlertToast

struct AddMemberMasterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memberStore: MemberMasterStore
  
    @Binding var isPresentedAddMemberAlert: Bool
    
    @State var isProcessing: Bool = false
    
    @State var name: String = ""
    @State var studentCode: String = ""
    @State var memberStatus: MemberStatus = .new
    let status: [MemberStatus] = [.new, .official, .graduated]
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("회원 등록")
                .font(.system(size: 32, weight: .semibold))
            
            Spacer()
            
            CustomTextField(style: .plain, title: "이름을 입력하세요.",
                            text: $name).customTextField
            CustomTextField(style: .studentCode,
                            title: "학번을 입력하세요.",
                            text: $studentCode).customTextField
            
            Picker("멤버 상태를 선택하세요",
                   selection: $memberStatus) {
                ForEach(status, id: \.self) {
                    Text("\($0.rawValue)")
                }
            }
            Spacer()
            
            CustomButton(style: .plain, action: {
                isProcessing = true
                Task {
                    await memberStore.addMember(
                        member:
                            Member(
                            studentCode: studentCode,
                            name: name,
                            memberStatus: memberStatus)
                    )
                    
                    isPresentedAddMemberAlert = true
                    isProcessing = false
                    dismiss()
                }
            }).customButton
                .disable(name.isEmpty || studentCode.isEmpty || isProcessing)
                
          
            Spacer()
            
        } // - VStack
        .disabled(isProcessing)
        .toast(isPresenting: $isPresentedAddMemberAlert) {
            AlertToast(displayMode: .alert,
                       type: .complete(.green),
                       title: "등록 완료!")
        }
        
    }
}

