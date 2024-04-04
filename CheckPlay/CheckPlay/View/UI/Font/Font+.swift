//
//  Font+.swift
//  CheckPlay
//
//  Created by sole on 1/10/24.
//

import SwiftUI

extension Font {
    // font를 구분하는 열거형입니다.
    // 열거형의 Element들은 Weight를 Element로 갖습니다.
    enum EPFont {
        enum Pretendard: String {
            case regular = "PretendardVariable-Regular"
            case thin = "PretendardVariable-Thin"
            case extraLight = "PretendardVariable-ExtraLight"
            case light = "PretendardVariable-Light"
            case medium = "PretendardVariable-Medium"
            case semibold = "PretendardVariable-SemiBold"
            case bold = "PretendardVariable-Bold"
            case extraBold = "PretendardVariable-ExtraBold"
            case black = "PretendardVariable-Black"
        }
    }

    // font의 size를 구분하는 열거형입니다.
    enum EPFontSize: CGFloat {
        case xxxs = 12
        case xxs = 14
        case xs = 18
        case s = 16
        case m = 20
        case l = 24
        case xl = 28
        case xxl = 32
    }
    
    // pretendard 폰트 적용
    static func pretendard(size: EPFontSize,
                           weight: EPFont.Pretendard) -> Font {
        return .custom(weight.rawValue,
                size: size.rawValue)
    }
}

extension Text {
    func pretendard(size: Font.EPFontSize,
                           weight: Font.EPFont.Pretendard) -> Text {
        return self.font(.pretendard(size: size,
                                 weight: weight))
    }
}

extension View {
    func pretendard(size: Font.EPFontSize,
                           weight: Font.EPFont.Pretendard) -> some View {
        return self.font(.pretendard(size: size,
                                 weight: weight))
    }
}

