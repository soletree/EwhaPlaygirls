//
//  CustomButton.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI



struct CustomButton {
    public enum CustomButtonStyle {
        case plain
        case check
        case request
        case login
        case logout
        case signUp
        case verifyEmail
        case change
    }
   
    let customButton: CustomButtonView
    
    struct CustomButtonView: View {
        public let style: CustomButtonStyle
        public let action: () -> Void
        private var buttonText: String {
            switch style {
            case .plain:
                return "확인"
            case .check:
                return "출석하기"
            case .request:
                return "제출하기"
            case .login:
                return "로그인"
            case .logout:
                return "로그아웃"
            case .signUp:
                return "회원가입"
            case .verifyEmail:
                return "확인"
            case .change:
                return "변경하기"
            }
            
            
        }
        private var screenSizeRatio: (Double, Double) {
            if style == .verifyEmail {
                return (0.15, 0.04)
            } else {
                return (0.8, 0.07)
            }
        }
        
        private var buttonTextSize: Font {
            if style == .verifyEmail {
                return .subheadline.bold()
            } else {
                return .title3.bold()
            }
        }
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.customGreen)
                        .frame(width: UIScreen.screenWidth * screenSizeRatio.0, height: UIScreen.screenHeight * screenSizeRatio.1)
                    
                    Text("\(buttonText)")
                        .font(buttonTextSize)
                        .foregroundColor(.white)
                    
                }
            }
        }
        
        public func disable(_ isDisable: Bool) -> some View {
            if isDisable {
                return
                AnyView(ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.customLightGray)
                        .frame(width: UIScreen.screenWidth * screenSizeRatio.0, height: UIScreen.screenHeight * screenSizeRatio.1)
                    
                    Text("\(buttonText)")
                        .font(buttonTextSize)
                        .foregroundColor(.white)
                    
                })
            } else {
                return AnyView(body)
            }
        }
        
    } // - CustomButtonView
    
    
    
    init(style: CustomButtonStyle, action: @escaping () -> Void) {
        customButton = .init(style: style, action: action)
    }
}


