//
//  CustomTextField.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI

struct CustomTextField {
    enum CustomTextFieldStyle {
        case plain
        case secure
        case studentCode
        case email
    }
    let customTextField: CustomTextFieldView
    
    struct CustomTextFieldView: View {
        public let style: CustomTextFieldStyle
        public let title: String
        @Binding var text: String
        @State private var isSecureField: Bool = true
        var body: some View {
            switch style {
            case .plain:
                plainStyle
            case .secure:
                secureStyleWithEyeButton
            case .studentCode:
                studentCodeStyle
            case .email:
                emailStyle
            }
        
            
            
        }
        //MARK: - View(plainStyle)
        private var plainStyle: some View {
            TextField("\(title)", text: $text)
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.05)
                .textFieldStyle(.roundedBorder)
                
            
        } // - plainStyle
        private var secureStyle: some View {
                SecureField("\(title)", text: $text)
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.05)
                .textFieldStyle(.roundedBorder)
                
        }
        private var secureStyleWithEyeButton: some View {
            VStack {
                if isSecureField {
                    secureStyle
                } else {
                    plainStyle
                }
            } // - VStack
            .overlay(alignment: .trailing) {
                    Button(action: {
                        isSecureField.toggle()
                    }) {
                        Image(systemName: isSecureField ? "eye.slash.fill": "eye.fill")
                            .foregroundColor(.customGreen)
                    }
                }
        }
        
        //MARK: - View(plainStyle)
        private var studentCodeStyle: some View {
            TextField("\(title)", text: $text)
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.05)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
        } // - plainStyle
        
        //MARK: - View(plainStyle)
        private var emailStyle: some View {
            TextField("\(title)", text: $text)
                .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.05)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
            
        } // - plainStyle
        
    }
    init(style: CustomTextFieldStyle, title: String, text: Binding<String>){
        customTextField = .init(style: style, title: title, text: text)
    }
    
}

struct CustomTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.06)
            .textFieldStyle(.roundedBorder)
    }
}

//MARK: - ViewModifier(CustomTextEditorModifier)
struct CustomTextEditorModifier: ViewModifier {
    let title: String
    @Binding var text: String
    func body(content: Content) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.customLightGray, lineWidth: 2)
            .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.2)
            .overlay {
                content
                    .frame(width: UIScreen.screenWidth * 0.75, height: UIScreen.screenHeight * 0.17)
                    .overlay(alignment: .topLeading) {
                        // 플레이스 홀더입니다.
                        if text.isEmpty {
                            Text("\(title)")
                                .foregroundColor(.customLightGray)
                                .padding(7)
                        }
                    }
            }
    }
} // - CustomTextEditorModifier




