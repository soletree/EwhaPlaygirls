//
//  ColorExtension.swift
//  CheckPlay
//
//  Created by sole on 2023/02/20.
//

import SwiftUI


// Custom Color Extension
extension Color {
    static let black300 = Color(hex: 0x151515)
    static let black200 = Color(hex: 0x242424)
    static let black100 = Color(hex: 0x383838)
    static let gray300 = Color(hex: 0x616161)
    static let gray200 = Color(hex: 0xDFDFDF)
    static let gray100 = Color(hex: 0xE6EDEA)
    
    static let brandColor = Color(hex: 0x00462A)
    
    static let subColor300 = Color(hex: 0x4D7E6A)
    static let subColor200 = Color(hex: 0x99B5AA)
    static let subColor100 = Color(hex: 0xE6EDEA)
    
//    static let customLightGreen = Color(hex: 0x5CAD83)
    
    static let pointColor = Color(hex: 0xE3D12C)
    
    static let mapCircleOutlineRed = Color(hex: 0xEA3323)
    static let mapCircleFilledRed = Color(hex: 0xEA3323, alpha: 0.4)
    
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
