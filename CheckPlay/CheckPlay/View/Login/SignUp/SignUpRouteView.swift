//
//  SignUpRouteView.swift
//  CheckPlay
//
//  Created by sole on 2023/03/21.
//

import SwiftUI

struct SignUpRouteView: View {
    @State var isMember: Bool = false
    @State var signUpInfo: SignUpInfo = .init()
    
    var body: some View {
        if !isMember {
            TypeStudentCodeAndNameView(isMember: $isMember, signUpInfo: $signUpInfo)
        } else {
            TypeEmailAndPasswordView(signUpInfo: $signUpInfo)
        }
    }
}

struct TypeEmailAndPasswordView: View {
    @Binding var signUpInfo: SignUpInfo
    @State var isTypedEmail: Bool = false
    var body: some View {
        if !isTypedEmail {
            TypeEmailView(isTypedEmail: $isTypedEmail, signUpInfo: $signUpInfo)
        } else {
            TypePasswordView(signUpInfo: $signUpInfo)
        }
    }
}

struct SignUpInfo {
    var name: String = ""
    var studentCode: String = ""
    var email: String = ""
}
