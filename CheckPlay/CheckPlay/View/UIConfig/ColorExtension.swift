//
//  ColorExtension.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI


// Custom Color Extension
extension Color {
    static let customBlack = Color(hex: 0x151515)
    static let customSemiBlack = Color(hex: 0x242424)
    static let customMiddleBlack = Color(hex: 0x383838)
    static let customGray = Color(hex: 0x616161)
    static let customLightGray = Color(hex: 0xDFDFDF)
    static let customGreen = Color(hex: 0x2D6040)
    static let customLightGreen = Color(hex: 0x5CAD83)
    
    static let customYellow = Color(hex: 0xF4CE4A)
    static let customCircleOutlineRed = Color(hex: 0xEA3323)
    static let customCircleFillRed = Color(hex: 0xEA3323, alpha: 0.4)
    
    // hex 값으로 색을 초기화합니다.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
