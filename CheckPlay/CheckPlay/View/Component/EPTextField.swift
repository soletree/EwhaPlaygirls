//
//  EPTextField.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI

struct EPTextField: View {
    enum EPTextFieldStyle {
        case plain
        case secure
        case studentCode
        case email
    }
    
    public let style: EPTextFieldStyle
    public let title: String
    
    @Binding var text: String
    
    @State private var isSecureField: Bool = true
      
    var body: some View {
        switch style {
        case .plain:
            plainStyle
                .modifier(EPTextFieldModifier())
        case .secure:
            secureStyle
                .modifier(EPTextFieldModifier())
        case .studentCode:
            studentCodeStyle
                .modifier(EPTextFieldModifier())
        case .email:
            emailStyle
                .modifier(EPTextFieldModifier())
        }
    }
    //MARK: - View(plainStyle)
    var plainStyle: some View {
        TextField("\(title)", text: $text)
    } // - plainStyle
    
    //MARK: - secure
    private var secureStyle: some View {
        HStack {
            if isSecureField {
                SecureField("\(title)",
                            text: $text)
            } else {
                TextField("\(title)", text: $text)
            }
            Spacer()
            
            Button {
                isSecureField.toggle()
            } label: {
                Image(systemName: isSecureField ? "eye.slash.fill": "eye.fill")
                    .foregroundStyle(Color.brandColor)
            }
            .frame(width: 24,
                   height: 24)
        }
    }
    
    //MARK: - studentCode
    private var studentCodeStyle: some View {
        TextField("\(title)",
                  text: $text)
            .keyboardType(.numberPad)
        
    } // - studentCodeStyle
    
    //MARK: - email
    private var emailStyle: some View {
        TextField("\(title)",
                  text: $text)
            .keyboardType(.emailAddress)
        
    } // - emailStyle
}

//MARK: - EPTextFieldModifier
struct EPTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .pretendard(size: .xs,
                        weight: .regular)
            .textFieldStyle(.plain)
            .foregroundStyle(Color.black300)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color.gray200)
            }
    }
}

//MARK: - ViewModifier(EPTextEditorModifier)
struct EPTextEditorModifier: ViewModifier {
    let title: String
    @Binding var text: String
    func body(content: Content) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray200,
                    lineWidth: 2)
            .overlay {
                content
                    .overlay(alignment: .topLeading) {
                        // 플레이스 홀더입니다.
                        if text.isEmpty {
                            Text("\(title)")
                                .foregroundStyle(Color.gray200)
                                .padding(7)
                        }
                    }
            }
    }
} // - CustomTextEditorModifier



//MARK: - Preview
#Preview {
    EPTextField(style: .secure,
                    title: "텍스트를 입력하세요",
                    text: .constant(""))
}

