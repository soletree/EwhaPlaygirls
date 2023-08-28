//
//  EmptyAttendanceView.swift
//  CheckPlay
//
//  Created by sole on 2023/08/28.
//

import SwiftUI

struct EmptyAttendanceView: View {
    var body: some View {
        VStack {
            Image(systemName: "xmark.bin")
                .resizable()
                .frame(width: UIScreen.screenHeight * 0.2,
                       height: UIScreen.screenWidth * 0.3)
                .padding(10)
                .foregroundColor(.customLightGray)
            
            Text("출석 현황이")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.customLightGray)
            
            Text("아직 없습니다!")
                .font(.system(size: 25, weight: .semibold))
                .foregroundColor(.customLightGray)

        }
    }
}
