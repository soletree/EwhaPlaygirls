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
